/* Copyright (c) 2006-2007 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#import <Foundation/NSObject.h>

@class NSButton, NSImage, NSArray, NSWindow, NSError, NSView, NSMutableArray;

typedef enum {
    NSWarningAlertStyle,
    NSInformationalAlertStyle,
    NSCriticalAlertStyle,
} NSAlertStyle;

enum {
    NSAlertFirstButtonReturn = 1000,
    NSAlertSecondButtonReturn = 1001,
    NSAlertThirdButtonReturn = 1002,
};

typedef NSInteger NSModalResponse;

@interface NSAlert : NSObject {
    id _delegate;
    NSAlertStyle _style;
    NSImage *_icon;
    NSString *_messageText;
    NSString *_informativeText;
    NSView *_accessoryView;
    BOOL _showsHelp;
    BOOL _showsSuppressionButton;
    NSString *_helpAnchor;
    NSMutableArray *_buttons;
    NSButton *_suppressionButton;
    NSWindow *_window;

    BOOL _needsLayout;
    id _sheetDelegate;
    SEL _sheetDidEnd;
}

+ (NSAlert *) alertWithError: (NSError *) error;
+ (NSAlert *) alertWithMessageText: (NSString *) messageText
                     defaultButton: (NSString *) defaultTitle
                   alternateButton: (NSString *) alternateTitle
                       otherButton: (NSString *) otherTitle
         informativeTextWithFormat: (NSString *) format, ...;

- delegate;
- (NSAlertStyle) alertStyle;
- (NSImage *) icon;
- (NSString *) messageText;
- (NSString *) informativeText;
- (NSView *) accessoryView;
- (BOOL) showsHelp;
- (BOOL) showsSuppressionButton;
- (NSString *) helpAnchor;
- (NSArray *) buttons;
- (NSButton *) suppressionButton;
- window;

- (void) setDelegate: delegate;
- (void) setAlertStyle: (NSAlertStyle) value;
- (void) setIcon: (NSImage *) value;
- (void) setMessageText: (NSString *) value;
- (void) setInformativeText: (NSString *) value;
- (void) setAccessoryView: (NSView *) value;
- (void) setShowsHelp: (BOOL) value;
- (void) setShowsSuppressionButton: (BOOL) value;
- (void) setHelpAnchor: (NSString *) value;

- (NSButton *) addButtonWithTitle: (NSString *) title;

- (void) layout;

- (void) beginSheetModalForWindow: (NSWindow *) window
                    modalDelegate: delegate
                   didEndSelector: (SEL) selector
                      contextInfo: (void *) info;
- (void) beginSheetModalForWindow: (NSWindow *) sheetWindow
                completionHandler:
                        (void (^)(NSModalResponse returnCode)) handler;
- (NSInteger) runModal;

@end

@protocol NSAlertDelegate <NSObject>
- (BOOL) alertShowHelp: (NSAlert *) alert;
@end
