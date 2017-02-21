//
//  keyProcessor.m
//  vkKeyBind
//
//  Created by andrux on 2/20/17.
//  Copyright © 2017 test. All rights reserved.
//

#import "KeyProcessor.h"

#import <stdio.h>
#import <time.h>
#import <string.h>
#import <ApplicationServices/ApplicationServices.h>
#import <Carbon/Carbon.h>
#import <AppKit/AppKit.h>

@interface KeyProcessor()
//    @property(strong, nonatomic) NSMutableArray<KeyProcessorDelegate>* observers;

@end

@implementation KeyProcessor
+ (KeyProcessor *)sharedInstance{
    static dispatch_once_t  onceToken;
    static KeyProcessor * sSharedInstance;
    NSLog(@"sharedInstance CALL");
    dispatch_once(&onceToken, ^{
        sSharedInstance = [KeyProcessor new];
        sSharedInstance.state = NO;
//        sSharedInstance.observers = [NSMutableArray<KeyProcessorDelegate> new];
    });
    
    return sSharedInstance;
}

//-(void)dealloc{
//    [self.observers removeAllObjects];
//    self.observers = nil;
//}


//-(void)addEventListener:(id<KeyProcessorDelegate>)object{
//    
//}

-(BOOL)start{
    NSDictionary *options = @{(__bridge id)kAXTrustedCheckOptionPrompt: @NO};
    BOOL accessibilityEnabled = AXIsProcessTrustedWithOptions((CFDictionaryRef)options);
    
    if(accessibilityEnabled){
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
                self.state = YES;
            }
        }

    
    }
    
    return accessibilityEnabled;
}

CGEventRef CGEventCallback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *refcon) {
    if (type != kCGEventKeyDown && type != kCGEventFlagsChanged  && type != kCGEventKeyUp) { return event; }
    
//    CGKeyCode keyCode = (CGKeyCode) CGEventGetIntegerValueField(event, kCGKeyboardEventKeycode);
//    CGEventFlags flagsP = CGEventGetFlags(event);
//    BOOL isKeyCMD = (flagsP & kCGEventFlagMaskCommand) == kCGEventFlagMaskCommand;
//    BOOL isKeyALT = (flagsP & kCGEventFlagMaskAlternate) == kCGEventFlagMaskAlternate;
//    BOOL isKeyCTRL = (flagsP & kCGEventFlagMaskControl) == kCGEventFlagMaskControl;
    
    
    [KeyProcessor sharedInstance].event = [NSEvent eventWithCGEvent:event];
    
//    
//    for(id<KeyProcessorDelegate> delegate in [[KeyProcessor sharedInstance] observers])
//    {
//        if ([delegate respondsToSelector:@selector(KeyProcessorEvent:)]) {
//            NSEvent *theEvent = [NSEvent eventWithCGEvent:event];
//            [delegate KeyProcessorEvent:theEvent];
//        }
//    }
    
//    NSLog(@"%i, ALT:%@ CTRL:%@ CMD:%@",keyCode,
//          isKeyALT ? @"Yes" : @"No",
//          isKeyCTRL ? @"Yes" : @"No",
//          isKeyCMD ? @"Yes" : @"No"
//          );
//    NSEvent *theEvent = [NSEvent eventWithCGEvent:event];
//    NSEventModifierFlags flagsP2 = theEvent.modifierFlags;
//    NSLog(@"======%i",flagsP2);
    
//    if (keyCode == 18 && isKeyALT) {
//        [(AppDelegate*)[NSApplication sharedApplication].delegate callOSAScript];
//    }
    return event;
}



@end
