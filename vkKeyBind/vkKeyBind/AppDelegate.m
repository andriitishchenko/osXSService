//
//  AppDelegate.m
//  vkKeyBind
//
//  Created by andrux on 2/15/17.
//  Copyright © 2017 test. All rights reserved.
//

#import "AppDelegate.h"

#include <stdio.h>
#include <time.h>
#include <string.h>
#include <ApplicationServices/ApplicationServices.h>
#include <Carbon/Carbon.h>

@interface AppDelegate ()
@property (strong, nonatomic) NSStatusItem *statusItem;
@end

@implementation AppDelegate

CGEventRef CGEventCallback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *refcon) {
    if (type != kCGEventKeyDown && type != kCGEventFlagsChanged  && type != kCGEventKeyUp) { return event; }
    
    CGKeyCode keyCode = (CGKeyCode) CGEventGetIntegerValueField(event, kCGKeyboardEventKeycode);
    CGEventFlags flagsP = CGEventGetFlags(event);
    BOOL isKeyCMD = (flagsP & kCGEventFlagMaskCommand) == kCGEventFlagMaskCommand;
    BOOL isKeyALT = (flagsP & kCGEventFlagMaskAlternate) == kCGEventFlagMaskAlternate;
    BOOL isKeyCTRL = (flagsP & kCGEventFlagMaskControl) == kCGEventFlagMaskControl;
    NSLog(@"%i, ALT:%@ CTRL:%@ CMD:%@",keyCode,
          isKeyALT ? @"Yes" : @"No",
          isKeyCTRL ? @"Yes" : @"No",
          isKeyCMD ? @"Yes" : @"No"
          );
    return event;
}
-(void)keyHandlerRegister{
    
    CGEventMask eventMask = (1 << kCGEventKeyDown);
    CFRunLoopSourceRef  eventSrc;
    CFMachPortRef machPortRef =
    
    CGEventTapCreate(
                     kCGSessionEventTap,
                     kCGHeadInsertEventTap,
                     0,
                     eventMask,
                     CGEventCallback,
                     NULL
                     );
    

    
    
    
    if (machPortRef == NULL)
    {
        printf("CGEventTapCreate failed!\n");
    } else {
        eventSrc = CFMachPortCreateRunLoopSource(NULL, machPortRef, 0);
        if ( eventSrc == NULL )
        {
            printf( "No event run loop src?\n" );
        }else {
            CFRunLoopRef runLoop =  CFRunLoopGetCurrent(); //GetCFRunLoopFromEventLoop(GetMainEventLoop ());
            
            // Get the CFRunLoop primitive for the Carbon Main Event Loop, and add the new event souce
            CFRunLoopAddSource(runLoop, eventSrc, kCFRunLoopDefaultMode);
        }
    }
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    NSStatusBar *statusBar = [NSStatusBar systemStatusBar];
    _statusItem = [statusBar statusItemWithLength:NSSquareStatusItemLength];
    
    NSImage *icon = [NSImage imageNamed:@"icon_menu"];
    icon.template = YES;
    
    _statusItem.button.image = icon;
    [_statusItem setAction:@selector(itemClicked:)];
    
//    if (AXIsProcessTrustedWithOptions != NULL) {
//        // 10.9 and later
//        const void * keys[] = { kAXTrustedCheckOptionPrompt };
//        const void * values[] = { kCFBooleanTrue };
//        
//        CFDictionaryRef options = CFDictionaryCreate(
//                                                     kCFAllocatorDefault,
//                                                     keys,
//                                                     values,
//                                                     sizeof(keys) / sizeof(*keys),
//                                                     &kCFCopyStringDictionaryKeyCallBacks,
//                                                     &kCFTypeDictionaryValueCallBacks);
//        
//         AXIsProcessTrustedWithOptions(options);
//    }
    
    
    NSDictionary *options = @{(__bridge id)kAXTrustedCheckOptionPrompt: @NO};
    BOOL accessibilityEnabled = AXIsProcessTrustedWithOptions((CFDictionaryRef)options);
    if (!accessibilityEnabled) {
        NSString *urlString = @"x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility";
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:urlString]];
        [[NSApplication sharedApplication] terminate:self];
    }
    else
    {
        [self keyHandlerRegister ];
    }
}

- (void)itemClicked:(id)sender {
    //Look for control click, close app if so
    NSEvent *event = [NSApp currentEvent];
    if([event modifierFlags] & NSEventModifierFlagControl) {
        [[NSApplication sharedApplication] terminate:self];
        return;
    }
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    
}


@end
