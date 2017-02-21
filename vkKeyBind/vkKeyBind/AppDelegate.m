//
//  AppDelegate.m
//  vkKeyBind
//
//  Created by andrux on 2/15/17.
//  Copyright © 2017 test. All rights reserved.
//

#import "AppDelegate.h"
#import "DB.h"
#import "KeyProcessor.h"

@interface AppDelegate ()
@property (strong, nonatomic) NSStatusItem *statusItem;
//@property (strong, nonatomic) NSWindow *window;

@end

@implementation AppDelegate

static void *KeyProcessorEventContext = &KeyProcessorEventContext;

//CGEventRef CGEventCallback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *refcon) {
//    if (type != kCGEventKeyDown && type != kCGEventFlagsChanged  && type != kCGEventKeyUp) { return event; }
//    
//    CGKeyCode keyCode = (CGKeyCode) CGEventGetIntegerValueField(event, kCGKeyboardEventKeycode);
//    CGEventFlags flagsP = CGEventGetFlags(event);
//    BOOL isKeyCMD = (flagsP & kCGEventFlagMaskCommand) == kCGEventFlagMaskCommand;
//    BOOL isKeyALT = (flagsP & kCGEventFlagMaskAlternate) == kCGEventFlagMaskAlternate;
//    BOOL isKeyCTRL = (flagsP & kCGEventFlagMaskControl) == kCGEventFlagMaskControl;
//    NSLog(@"%i, ALT:%@ CTRL:%@ CMD:%@",keyCode,
//          isKeyALT ? @"Yes" : @"No",
//          isKeyCTRL ? @"Yes" : @"No",
//          isKeyCMD ? @"Yes" : @"No"
//          );
//    NSEvent *theEvent = [NSEvent eventWithCGEvent:event];
//    NSEventModifierFlags flagsP2 = theEvent.modifierFlags;
//    NSLog(@"======%i",flagsP2);
//    
//    if (keyCode == 18 && isKeyALT) {
//        [(AppDelegate*)[NSApplication sharedApplication].delegate callOSAScript];
//    }
//    return event;
//}
//-(void)keyHandlerRegister{
//    
//    CGEventMask eventMask = (1 << kCGEventKeyDown);
//    CFRunLoopSourceRef  eventSrc;
//    CFMachPortRef machPortRef =
//    
//    CGEventTapCreate(
//                     kCGSessionEventTap,
//                     kCGHeadInsertEventTap,
//                     0,
//                     eventMask,
//                     CGEventCallback,
//                     NULL
//                     );
//    
//
//    
//    
//    
//    if (machPortRef == NULL)
//    {
//        printf("CGEventTapCreate failed!\n");
//    } else {
//        eventSrc = CFMachPortCreateRunLoopSource(NULL, machPortRef, 0);
//        if ( eventSrc == NULL )
//        {
//            printf( "No event run loop src?\n" );
//        }else {
//            CFRunLoopRef runLoop =  CFRunLoopGetCurrent(); //GetCFRunLoopFromEventLoop(GetMainEventLoop ());
//            
//            // Get the CFRunLoop primitive for the Carbon Main Event Loop, and add the new event souce
//            CFRunLoopAddSource(runLoop, eventSrc, kCFRunLoopDefaultMode);
//        }
//    }
//}

-(void)coreTestData{
    NSArray *results = [DB getKeyBinds];
    
    if( [results count] ==0  ){
        [DB addDemo];
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
    
    
    if (![[KeyProcessor sharedInstance] start]) {
        NSString *urlString = @"x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility";
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:urlString]];
        [[NSApplication sharedApplication] terminate:self];
    }
    else{
        [[KeyProcessor sharedInstance] addObserver:self
                  forKeyPath:@"event"
                     options:(NSKeyValueObservingOptionNew |
                              NSKeyValueObservingOptionOld)
                     context:KeyProcessorEventContext];
    }
        
    [self coreTestData];
}


- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    if (context == KeyProcessorEventContext) {
        NSEvent * newValue = [change objectForKey:NSKeyValueChangeNewKey];
        [self onEvent:newValue];
        
    } else {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}

-(void)onEvent:(NSEvent*)event{
    NSEventModifierFlags flagsP = event.modifierFlags;
    BOOL isCmd = (flagsP & kCGEventFlagMaskCommand) == kCGEventFlagMaskCommand;
    BOOL isAlt = (flagsP & kCGEventFlagMaskAlternate) == kCGEventFlagMaskAlternate;
    BOOL isCtrl = (flagsP & kCGEventFlagMaskControl) == kCGEventFlagMaskControl;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"keyCode == %@ AND isCtrl == %@ AND isAlt == %@ AND isCmd == %@",
                              @(event.keyCode),
                              @(isCtrl),
                              @(isAlt),
                              @(isCmd)
                              ];
    NSArray*list = [DB getKeyBindsWithPredicate:predicate];
    
    for (KeyBind*obj in list){
        RunScript*rs = obj.runScript;
        NSLog(@"CMD == %@",rs.cmd);
        [self callOSAScript:rs.cmd];
    }
}

- (void)itemClicked:(id)sender {
    //Look for control click, close app if so
    NSEvent *event = [NSApp currentEvent];
    if([event modifierFlags] & NSEventModifierFlagControl) {
        [[NSApplication sharedApplication] terminate:self];
        return;
    }
//    [[NSApplication sharedApplication].keyWindow makeKeyAndOrderFront:nil];
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
    [[NSApplication sharedApplication].mainWindow makeKeyAndOrderFront:self];
}


-(void)callOSAScript:(NSString*)cmd{
    if (!cmd) {
        NSLog(@"CMD == NIL!");
        return;
    }
    NSDictionary* errorDict;
    NSAppleEventDescriptor* returnDescriptor = NULL;
    
    NSAppleScript* scriptObject = [[NSAppleScript alloc] initWithSource:
                                  cmd];
    
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
//
//-(void)callOSAScript{
//    //https://developer.apple.com/library/content/technotes/tn2084/_index.html
//    NSDictionary* errorDict;
//    NSAppleEventDescriptor* returnDescriptor = NULL;
//    
//    NSAppleScript* scriptObject = [[NSAppleScript alloc] initWithSource:
// @"display notification \"Pressed ALT+1\" with title \"Hi from AppleScript!\""
//                                   
////                                   @"\
////                                   set app_path to path to me\n\
////                               ¡    tell application \"System Events\"\n\
////                                   if \"AddLoginItem\" is not in (name of every login item) then\n\
////                                   make login item at end with properties {hidden:false, path:app_path}\n\
////                                   end if\n\
////                                   end tell"
//                                   
//                                   ];
//    
//    returnDescriptor = [scriptObject executeAndReturnError: &errorDict];
//    if (returnDescriptor != NULL)
//    {
//        // successful execution
//        if (kAENullEvent != [returnDescriptor descriptorType])
//        {
//            // script returned an AppleScript result
//            if (cAEList == [returnDescriptor descriptorType])
//            {
//                // result is a list of other descriptors
//            }
//            else
//            {
//                // coerce the result to the appropriate ObjC type
//            }
//        } 
//    }
//    else
//    {
//        NSLog(@"%@", @"Some error!");
//    }
//}


- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
    if (flag) {
        return NO;
    }
    else
    {
        //[YourWindow makeKeyAndOrderFront:self];// Window that you want open while click on dock app icon
        return YES;
    }
}


//- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
//    // Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
////    return [[[DB sharedInstance] managedObjectContext] undoManager];
//}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    // Save changes in the application's managed object context before the application terminates.
//    NSManagedObjectContext *context = [[DB sharedInstance] managedObjectContext];
//    
//    if (!context) {
//        return NSTerminateNow;
//    }
//    
//    if (![context commitEditing]) {
//        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
//        return NSTerminateCancel;
//    }
//    
//    if (!context.hasChanges) {
//        return NSTerminateNow;
//    }
//    
//    NSError *error = nil;
//    if (![context save:&error]) {
//        
//        // Customize this code block to include application-specific recovery steps.
//        BOOL result = [sender presentError:error];
//        if (result) {
//            return NSTerminateCancel;
//        }
//        
//        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
//        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
//        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
//        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
//        NSAlert *alert = [[NSAlert alloc] init];
//        [alert setMessageText:question];
//        [alert setInformativeText:info];
//        [alert addButtonWithTitle:quitButton];
//        [alert addButtonWithTitle:cancelButton];
//        
//        NSInteger answer = [alert runModal];
//        
//        if (answer == NSAlertSecondButtonReturn) {
//            return NSTerminateCancel;
//        }
//    }
    
    return NSTerminateNow;
}

- (void)dealloc {
    [[KeyProcessor sharedInstance] removeObserver:self
                                       forKeyPath:@"event"
                                          context:KeyProcessorEventContext];
}


@end
