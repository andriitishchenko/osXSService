//
//  RunScript+CoreDataProperties.h
//  vkKeyBind
//
//  Created by andrux on 2/16/17.
//  Copyright © 2017 test. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#import "RunScript+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface RunScript (CoreDataProperties)

+ (NSFetchRequest<RunScript *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *cmd;
@property (nullable, nonatomic, copy) NSString *title;
@property (nullable, nonatomic, retain) KeyBind *keyBind;

@end

NS_ASSUME_NONNULL_END
