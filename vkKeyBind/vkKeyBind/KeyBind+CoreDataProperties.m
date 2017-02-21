//
//  KeyBind+CoreDataProperties.m
//  vkKeyBind
//
//  Created by andrux on 2/16/17.
//  Copyright © 2017 test. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#import "KeyBind+CoreDataProperties.h"

@implementation KeyBind (CoreDataProperties)

+ (NSFetchRequest<KeyBind *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"KeyBind"];
}

@dynamic keyCode;
@dynamic isCtrl;
@dynamic isAlt;
@dynamic isCmd;
@dynamic isEnabled;
@dynamic runScript;

@end
