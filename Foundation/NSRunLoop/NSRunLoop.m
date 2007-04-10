/* Copyright (c) 2006-2007 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

// Original - Christopher Lloyd <cjwl@objc.net>
#import <Foundation/NSRunLoop.h>
#import <Foundation/NSString.h>
#import <Foundation/NSThread.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSNotificationQueue-Private.h>
#import <Foundation/NSThread-Private.h>
#import <Foundation/NSDelayedPerform.h>
#import <Foundation/NSOrderedPerform.h>

#import <Foundation/NSRunLoopState.h>
#import <Foundation/NSRunLoop-InputSource.h>
#import <Foundation/NSPlatform.h>

NSString *NSDefaultRunLoopMode=@"NSDefaultRunLoopMode";

@implementation NSRunLoop

+(NSRunLoop *)currentRunLoop {
   return NSThreadSharedInstance(@"NSRunLoop");
}

-init {
   NSInputSource *parentDeath;

   _modes=NSCreateMapTableWithZone(NSObjectMapKeyCallBacks,NSObjectMapValueCallBacks,0,[self zone]);
   _currentMode=NSDefaultRunLoopMode;
   _orderedPerforms=[NSMutableArray new];

   if((parentDeath=[[NSPlatform currentPlatform] parentDeathInputSource])!=nil)
    [self addInputSource:parentDeath forMode:NSDefaultRunLoopMode];

   return self;
}

-(NSRunLoopState *)stateForMode:(NSString *)mode {
   NSRunLoopState *state=NSMapGet(_modes,mode);

   if(state==nil){
    state=[[NSRunLoopState new] autorelease];
    NSMapInsert(_modes,mode,state);
   }

   return state;
}

-(void)_orderedPerforms {
   int count=[_orderedPerforms count];

   while(--count>=0){
    NSOrderedPerform *check=[_orderedPerforms objectAtIndex:count];

    if([check fireInMode:_currentMode])
     [_orderedPerforms removeObjectAtIndex:count];
   }
}

-(NSString *)currentMode {
   return _currentMode;
}

-(NSDate *)limitDateForMode:(NSString *)mode {
   NSRunLoopState *state=[self stateForMode:mode];
   
   if(![mode isEqualToString:_currentMode]){
    [_currentMode release];
    _currentMode=[mode retain];
    [state changingIntoMode:mode];
   }
   
   [self _orderedPerforms];

   return [state limitDateForMode:mode];
}

-(void)acceptInputForMode:(NSString *)mode beforeDate:(NSDate *)date {
   NSRunLoopState *state=[self stateForMode:mode];

   [[NSNotificationQueue defaultQueue] asapProcessMode:mode];

   if([[NSNotificationQueue defaultQueue] hasIdleNotificationsInMode:mode]){
    if(![state pollInputForMode:mode])
     [[NSNotificationQueue defaultQueue] idleProcessMode:mode];
   }
   else {
    [state acceptInputForMode:mode beforeDate:date];
   }
}

-(void)invalidateTimerWithDelayedPerform:(NSDelayedPerform *)delayed {
   NSMapEnumerator state=NSEnumerateMapTable(_modes);
   NSString       *mode;
   NSRunLoopState *modeState;

   while(NSNextMapEnumeratorPair(&state,(void **)&mode,(void **)&modeState))
    [modeState invalidateTimerWithDelayedPerform:delayed];
}

-(BOOL)runMode:(NSString *)mode beforeDate:(NSDate *)date {
   NSAutoreleasePool *pool=[NSAutoreleasePool new];
   NSDate            *limitDate=[self limitDateForMode:mode];

   if(limitDate!=nil){
    limitDate=[limitDate earlierDate:date];
    [self acceptInputForMode:mode beforeDate:limitDate];
   }

   [pool release];

   return (limitDate!=nil);
}

-(void)runUntilDate:(NSDate *)date {
   while([self runMode:NSDefaultRunLoopMode beforeDate:date])
    if([date timeIntervalSinceNow]<0)
     break;
}

-(void)run {
// Calling -run w/o a pool in place is valid, which is why we need one here
// for the NSDate. Could get rid of the pool if the date was not autoreleased.
   NSAutoreleasePool *pool=[NSAutoreleasePool new];
   NSDate            *future=[NSDate distantFuture];

   while([self runMode:NSDefaultRunLoopMode beforeDate:future])
    ;

   [pool release];
}

-(void)addInputSource:(NSInputSource *)source forMode:(NSString *)mode {
   [[self stateForMode:mode] addInputSource:source];
}

-(void)removeInputSource:(NSInputSource *)source forMode:(NSString *)mode {
   [[self stateForMode:mode] removeInputSource:source];
}

-(void)addTimer:(NSTimer *)timer forMode:(NSString *)mode {
   [[self stateForMode:mode] addTimer:timer];
}


-(void)performSelector:(SEL)selector target:target argument:argument order:(unsigned)order modes:(NSArray *)modes {
   NSOrderedPerform *perform=[NSOrderedPerform orderedPerformWithSelector:selector target:target argument:argument order:order modes:modes];
  int count=[_orderedPerforms count];

   while(--count>=0){
    NSOrderedPerform *check=[_orderedPerforms objectAtIndex:count];
    unsigned          checkOrder=[check order];

    if(checkOrder>order)
     break;
   }

   [_orderedPerforms insertObject:perform atIndex:count+1];
}

-(void)cancelPerformSelector:(SEL)selector target:target argument:argument {
   int count=[_orderedPerforms count];

   while(--count>=0){
    NSOrderedPerform *check=[_orderedPerforms objectAtIndex:count];

    if([check selector]==selector && [check target]==target && [check argument]==argument)
     [_orderedPerforms removeObjectAtIndex:count];
   }
}

@end

@implementation NSObject(NSDelayedPerform)

+(void)cancelPreviousPerformRequestsWithTarget:target
       selector:(SEL)selector object:argument {
   NSDelayedPerform *delayed=[NSDelayedPerform delayedPerformWithObject:target selector:selector
     argument:argument];

   [[NSRunLoop currentRunLoop] invalidateTimerWithDelayedPerform:delayed];
}

+(void)_delayedPerform:(NSTimer *)timer {
   NSDelayedPerform *delayed=[timer userInfo];

   [delayed perform];
}

+(void)object:object performSelector:(SEL)selector withObject:argument
            afterDelay:(NSTimeInterval)delay {
   NSDelayedPerform *delayed=[NSDelayedPerform delayedPerformWithObject:object selector:selector
     argument:argument];
   NSTimer          *timer;

   timer=[NSTimer scheduledTimerWithTimeInterval:delay
    target:[NSObject class] selector:@selector(_delayedPerform:)
    userInfo:delayed repeats:NO];
}

-(void)performSelector:(SEL)selector withObject:argument
            afterDelay:(NSTimeInterval)delay {
   [[self class] object:self performSelector:selector withObject:argument
      afterDelay:delay];
}

@end
