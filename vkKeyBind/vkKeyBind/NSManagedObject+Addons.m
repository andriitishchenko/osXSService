//
//  NSManagedObject+Addons.m
//  vkKeyBind
//
//  Created by andrux on 2/20/17.
//  Copyright © 2017 test. All rights reserved.
//

#import "NSManagedObject+Addons.h"

@implementation NSManagedObject (Addons)
+(instancetype)newObjectWithMOC:(NSManagedObjectContext*)moc{
    id mo = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class]) inManagedObjectContext: moc];
    return mo;
}

+(NSArray*)queryWithPredicate:(NSPredicate*)_predicate moc:(NSManagedObjectContext*)moc {
    NSLog(@"%@", _predicate);
//    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:moc];
    NSFetchRequest *request = [self fetchRequest];
//    [request setEntity:entity];

    if (_predicate!=nil) {
        [request setPredicate:_predicate];
    }
    NSError *error1=nil;
    NSArray *matching_objects = [moc executeFetchRequest:request error:&error1];
    if (error1 == nil) {
        return matching_objects;
    }
    else{
        NSLog(@"queryWithEntity: %@",[error1 localizedDescription]);
    }
    return nil;
}
@end
