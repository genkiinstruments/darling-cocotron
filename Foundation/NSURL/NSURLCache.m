/* Copyright (c) 2006-2007 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */
#import <Foundation/NSURLCache.h>
#import <Foundation/NSRaise.h>

@implementation NSURLCache

+(NSURLCache *)sharedURLCache {
   NSUnimplementedMethod();
   return nil;
}

+(void)setSharedURLCache:(NSURLCache *)cache {
   NSUnimplementedMethod();
}

-initWithMemoryCapacity:(unsigned)memoryCapacity diskCapacity:(unsigned)diskCapacity diskPath:(NSString *)diskPath {
   NSUnimplementedMethod();
   return nil;
}

-(unsigned)memoryCapacity {
   return _memoryCapacity;
}

-(unsigned)diskCapacity {
   return _diskCapacity;
}

-(unsigned)currentDiskUsage {
   NSUnimplementedMethod();
   return 0;
}

-(unsigned)currentMemoryUsage {
   NSUnimplementedMethod();
   return 0;
}

-(NSCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request {
   NSUnimplementedMethod();
   return nil;
}

-(void)setMemoryCapacity:(unsigned)memoryCapacity {
   NSUnimplementedMethod();
}

-(void)setDiskCapacity:(unsigned)diskCapacity {
   NSUnimplementedMethod();
}

-(void)storeCachedResponse:(NSCachedURLResponse *)response forRequest:(NSURLRequest *)request {
   NSUnimplementedMethod();
}

-(void)removeAllCachedResponses {
   NSUnimplementedMethod();
}

-(void)removeCachedResponseForRequest:(NSURLRequest *)request {
   NSUnimplementedMethod();
}

@end