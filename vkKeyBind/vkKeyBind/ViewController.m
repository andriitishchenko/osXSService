//
//  ViewController.m
//  vkKeyBind
//
//  Created by andrux on 2/15/17.
//  Copyright © 2017 test. All rights reserved.
//

#import "ViewController.h"
#import "DB.h"
#import "KeyProcessor.h"

#include <CoreFoundation/CoreFoundation.h>
#include <Carbon/Carbon.h>

@interface ViewController ()<NSTableViewDataSource, NSTableViewDelegate,
NSTextFieldDelegate>
@property(strong,nonatomic) NSMutableArray* datasource;
@property (weak) IBOutlet NSButton *buttonNewcmd;
@property (weak) IBOutlet NSButton *buttonSave;
@property (weak) IBOutlet NSTextField *tfTitle;
@property (weak) IBOutlet NSTextField *tfKey;
@property (weak) IBOutlet NSButton *md_ctrl;
@property (weak) IBOutlet NSButton *md_alt;
@property (weak) IBOutlet NSButton *md_cmd;

@property (unsafe_unretained) IBOutlet NSTextView *tf_cmd;

@property (nonatomic) NSInteger selectedIndex;

@property (weak) IBOutlet NSTableView *tebleView;

@end



@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.datasource = [DB getKeyBinds];

    // Do any additional setup after loading the view.
      [self refreshTable];
}

//-(void)dealloc{
//    [[KeyProcessor sharedInstance] removeObserver:self
//                                       forKeyPath:@"event"
//                                          context:KeyProcessorEventContext];
//}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return _datasource.count;
}


- (NSView *)tableView:(NSTableView *)tableView
   viewForTableColumn:(NSTableColumn *)tableColumn
                  row:(NSInteger)row {
    
    // Get an existing cell with the MyView identifier if it exists
    NSTextField *result = [tableView makeViewWithIdentifier:@"cell" owner:self];
    
    // There is no existing cell to reuse so create a new one
    if (result == nil) {
        
        // Create the new NSTextField with a frame of the {0,0} with the width of the table.
        // Note that the height of the frame is not really relevant, because the row height will modify the height.
        result = [[NSTextField alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
        
        // The identifier of the NSTextField instance is set to MyView.
        // This allows the cell to be reused.
        result.identifier = @"cell";
    }
    
    // result is now guaranteed to be valid, either as a reused cell
    // or as a new cell, so set the stringValue of the cell to the
    // nameArray value at row
    KeyBind* itm =  [self.datasource objectAtIndex:row];
    result.stringValue = itm.title;
    
    // Return the result
    return result;
}

- (void)keyUp:(NSEvent *)event {
    
    NSLog(@"Characters: %@", [event characters]);
    NSLog(@"KeyCode: %hu", [event keyCode]);
    
    self.tfKey.stringValue = [[event charactersIgnoringModifiers] uppercaseString];
    
//        
//    self.md_alt.state = isKeyALT==YES?NSOnState:NSOffState;
//    self.md_ctrl.state = isKeyCTRL==YES?NSOnState:NSOffState;
//    self.md_cmd.state = isKeyCMD==YES?NSOnState:NSOffState;
//    
//    NSLog(@"%i, ALT:%@ CTRL:%@ CMD:%@",keyCode,
//          isKeyALT ? @"Yes" : @"No",
//          isKeyCTRL ? @"Yes" : @"No",
//          isKeyCMD ? @"Yes" : @"No"
//          );

}

//-(void)tableViewSelectionDidChange:(NSNotification *)notification{
//    NSLog(@"%d",[[notification object] selectedRow]);
//}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)rowIndex {
    //NSLog(@"%i tapped!", rowIndex);
    self.selectedIndex = rowIndex;
    KeyBind* itm =  [self.datasource objectAtIndex:rowIndex];
    self.tfTitle.stringValue = itm.title;
    self.tf_cmd.string = itm.runScript.cmd;
    self.tfKey.stringValue = (__bridge NSString *)createStringForKey(itm.keyCode);
    
    self.md_alt.state = itm.isAlt==YES?NSOnState:NSOffState;
    self.md_ctrl.state = itm.isCtrl==YES?NSOnState:NSOffState;
    self.md_cmd.state = itm.isCmd==YES?NSOnState:NSOffState;

    return YES;
}

/* Returns string representation of key, if it is printable.
 * Ownership follows the Create Rule; that is, it is the caller's
 * responsibility to release the returned object. */
CFStringRef createStringForKey(CGKeyCode keyCode)
{
    TISInputSourceRef currentKeyboard = TISCopyCurrentKeyboardInputSource();
    CFDataRef layoutData =
    TISGetInputSourceProperty(currentKeyboard,
                              kTISPropertyUnicodeKeyLayoutData);
    const UCKeyboardLayout *keyboardLayout =
    (const UCKeyboardLayout *)CFDataGetBytePtr(layoutData);
    
    UInt32 keysDown = 0;
    UniChar chars[4];
    UniCharCount realLength;
    
    UCKeyTranslate(keyboardLayout,
                   keyCode,
                   kUCKeyActionDisplay,
                   0,
                   LMGetKbdType(),
                   kUCKeyTranslateNoDeadKeysBit,
                   &keysDown,
                   sizeof(chars) / sizeof(chars[0]),
                   &realLength,
                   chars);
    CFRelease(currentKeyboard);
    
    return CFStringCreateWithCharacters(kCFAllocatorDefault, chars, 1);
}

/* Returns key code for given character via the above function, or UINT16_MAX
 * on error. */
CGKeyCode keyCodeForChar(const char c)
{
    static CFMutableDictionaryRef charToCodeDict = NULL;
    CGKeyCode code;
    UniChar character = c;
    CFStringRef charStr = NULL;
    
    /* Generate table of keycodes and characters. */
    if (charToCodeDict == NULL) {
        size_t i;
        charToCodeDict = CFDictionaryCreateMutable(kCFAllocatorDefault,
                                                   128,
                                                   &kCFCopyStringDictionaryKeyCallBacks,
                                                   NULL);
        if (charToCodeDict == NULL) return UINT16_MAX;
        
        /* Loop through every keycode (0 - 127) to find its current mapping. */
        for (i = 0; i < 128; ++i) {
            CFStringRef string = createStringForKey((CGKeyCode)i);
            if (string != NULL) {
                CFDictionaryAddValue(charToCodeDict, string, (const void *)i);
//                CFRelease(string);
            }
        }
    }
    
    charStr = CFStringCreateWithCharacters(kCFAllocatorDefault, &character, 1);
    
    /* Our values may be NULL (0), so we need to use this function. */
    if (!CFDictionaryGetValueIfPresent(charToCodeDict, charStr,
                                       (const void **)&code)) {
        code = UINT16_MAX;
    }
    
//    CFRelease(charStr);
    return code;
}

- (IBAction)actionSave:(id)sender {
    
    
    if (self.tfKey.stringValue.length == 0) {
        return;
    }
    BOOL isCmd = (self.md_cmd.state == NSOnState?YES:NO);
    BOOL isAlt = self.md_alt.state == NSOnState?YES:NO;
    BOOL isCtrl = self.md_ctrl.state == NSOnState?YES:NO;
    NSString*cmd = self.tf_cmd.string;
    NSString*title = self.tfTitle.stringValue;
//    char ch =[self.tfKey.stringValue characterAtIndex:0];
//    CGKeyCode keyCode = (CGKeyCode)keyCodeForChar(ch);
//    
    CGKeyCode keyCode = 2;
    
    
    
    KeyBind* itm;
    NSManagedObjectContext *moc = [DB newMOC];
    if(self.selectedIndex != -1){
        itm =  [self.datasource objectAtIndex:self.selectedIndex];
    }
    else
    {
        itm =  [KeyBind newObjectWithMOC:moc];
        RunScript *rs = [RunScript newObjectWithMOC:moc];
        itm.runScript = rs;
        [moc save:nil];
    }
    
    itm.isAlt = isAlt;
    itm.isCmd = isCmd;
    itm.isCtrl = isCtrl;
    itm.keyCode = keyCode;
    itm.title = title;
    RunScript *rs = itm.runScript;
    rs.cmd = cmd;
    itm.runScript = rs;

    [DB saveContext:moc];
    
    [self refreshTable];
}

-(void)refreshTable{
    self.datasource = [DB getKeyBinds];
    [self.tebleView reloadData];
}

- (IBAction)actionNewScript:(id)sender {
    self.selectedIndex = -1;
    self.tfTitle.stringValue = @"";
    self.tf_cmd.string = @"";
    self.tfKey.stringValue = @"";
    
    self.md_alt.state = NSOffState;
    self.md_ctrl.state = NSOffState;
    self.md_cmd.state = NSOffState;
}

- (IBAction)actionDelete:(id)sender {
    if(self.selectedIndex == -1) return;
    KeyBind* itm =  [self.datasource objectAtIndex:self.selectedIndex];
    NSManagedObjectContext *moc = [DB newMOC];
    [moc deleteObject:itm.runScript];
    [moc deleteObject:itm];
    [DB saveContext:moc];
    [self refreshTable];
}


@end
