//
//  RunScript+CoreDataProperties.m
//  vkKeyBind
//
//  Created by andrux on 2/16/17.
//  Copyright © 2017 test. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#import "RunScript+CoreDataProperties.h"

@implementation RunScript (CoreDataProperties)

+ (NSFetchRequest<RunScript *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"RunScript"];
}

@dynamic cmd;
@dynamic title;
@dynamic keyBind;

@end
