//
//  NSManagedObject+Addons.h
//  vkKeyBind
//
//  Created by andrux on 2/20/17.
//  Copyright © 2017 test. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (Addons)
+(instancetype)newObjectWithMOC:(NSManagedObjectContext*)moc;
+(NSArray*)queryWithPredicate:(NSPredicate*)_predicate moc:(NSManagedObjectContext*)moc;
@end
