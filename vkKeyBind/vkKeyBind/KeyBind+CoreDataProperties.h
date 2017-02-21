//
//  KeyBind+CoreDataProperties.h
//  vkKeyBind
//
//  Created by andrux on 2/16/17.
//  Copyright © 2017 test. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#import "KeyBind+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface KeyBind (CoreDataProperties)

+ (NSFetchRequest<KeyBind *> *)fetchRequest;

@property (nonatomic) int32_t keyCode;
@property (nonatomic) BOOL isCtrl;
@property (nonatomic) BOOL isAlt;
@property (nonatomic) BOOL isCmd;
@property (nonatomic) BOOL isEnabled;
@property (nullable, nonatomic, copy) NSString *title;
@property (nullable, nonatomic, retain) RunScript *runScript;

@end

NS_ASSUME_NONNULL_END
