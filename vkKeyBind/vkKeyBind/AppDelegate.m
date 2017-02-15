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
    
    if (keyCode == 18 && isKeyALT) {
        [(AppDelegate*)[NSApplication sharedApplication].delegate callOSAScript];
    }
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
    _statusItem.toolTip = @"ctrl+click to QUIT";
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

-(void)callOSAScript{
    //https://developer.apple.com/library/content/technotes/tn2084/_index.html
    NSDictionary* errorDict;
    NSAppleEventDescriptor* returnDescriptor = NULL;
    
    NSAppleScript* scriptObject = [[NSAppleScript alloc] initWithSource:
 @"display notification \"Pressed ALT+1\" with title \"Hi from AppleScript!\""
                                   
//                                   @"\
//                                   set app_path to path to me\n\
//                               ¡    tell application \"System Events\"\n\
//                                   if \"AddLoginItem\" is not in (name of every login item) then\n\
//                                   make login item at end with properties {hidden:false, path:app_path}\n\
//                                   end if\n\
//                                   end tell"
                                   
                                   ];
    
    returnDescriptor = [scriptObject executeAndReturnError: &errorDict];
    if (returnDescriptor != NULL)
    {
        // successful execution
        if (kAENullEvent != [returnDescriptor descriptorType])
        {
            // script returned an AppleScript result
            if (cAEList == [returnDescriptor descriptorType])
            {
                // result is a list of other descriptors
            }
            else
            {
                // coerce the result to the appropriate ObjC type
            }
        } 
    }
    else
    {
        NSLog(@"%@", @"Some error!");
    }
}


@end
