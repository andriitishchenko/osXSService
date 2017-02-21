//
//  DB.h
//  vkKeyBind
//
//  Created by andrux on 2/20/17.
//  Copyright © 2017 test. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSManagedObject+Addons.h"
#include "RunScript+CoreDataClass.h"
#include "KeyBind+CoreDataClass.h"

@interface DB : NSObject
+ (DB *)sharedInstance;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;


+(NSManagedObjectContext *)newMOC;
+(NSArray*)queryWithEntity:(NSString*)entityName andPredicate:(NSPredicate*)_predicate moc:(NSManagedObjectContext*)moc;
+(void)removeObjects:(NSArray*)list moc:(NSManagedObjectContext*)moc;
+(void)saveContext:(NSManagedObjectContext *)managedObjectContext;
+(void)resetAllEntities:(NSString *)nameEntity inMoc:(NSManagedObjectContext*)moc;
+(void)resetEntities:(NSString *)nameEntity inMoc:(NSManagedObjectContext*)moc predicate:(NSPredicate*)predicate;
+(void)killDB;


//
+(NSArray*)getKeyBinds;
+(NSArray*)getKeyBindsWithPredicate:(NSPredicate*)filter;


// Utils
+(void)addDemo;

@end
