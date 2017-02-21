//
//  DB.m
//  vkKeyBind
//
//  Created by andrux on 2/20/17.
//  Copyright © 2017 test. All rights reserved.
//

#import "DB.h"
#import "AppDelegate.h"


#define ApplicationDelegate ((AppDelegate *)[[UIApplication sharedApplication] delegate])


@interface DB()
    @property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@end

@implementation DB

+ (DB *)sharedInstance{
    static dispatch_once_t  onceToken;
    static DB * sSharedInstance;
    NSLog(@"sharedInstance CALL");
    dispatch_once(&onceToken, ^{
        sSharedInstance = [DB new];
        
    });
    
    return sSharedInstance;
}




#pragma mark - Core Data stack
//
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.coredataTestApp" in the user's Application Support directory.
    NSURL *appSupportURL = [[[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    return [appSupportURL URLByAppendingPathComponent:@"com.vkKeyBind"];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"coredataTestApp" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationDocumentsDirectory = [self applicationDocumentsDirectory];
    BOOL shouldFail = NO;
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    
    // Make sure the application files directory is there
    NSDictionary *properties = [applicationDocumentsDirectory resourceValuesForKeys:@[NSURLIsDirectoryKey] error:&error];
    if (properties) {
        if (![properties[NSURLIsDirectoryKey] boolValue]) {
            failureReason = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationDocumentsDirectory path]];
            shouldFail = YES;
        }
    } else if ([error code] == NSFileReadNoSuchFileError) {
        error = nil;
        [fileManager createDirectoryAtPath:[applicationDocumentsDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    if (!shouldFail && !error) {
        NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
        NSURL *url = [applicationDocumentsDirectory URLByAppendingPathComponent:@"coredataTestApp.storedata"];
        if (![coordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            
            /*
             Typical reasons for an error here include:
             * The persistent store is not accessible, due to permissions or data protection when the device is locked.
             * The device is out of space.
             * The store could not be migrated to the current model version.
             Check the error message to determine what the actual problem was.
             */
            coordinator = nil;
        }
        _persistentStoreCoordinator = coordinator;
    }
    
    if (shouldFail || error) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        if (error) {
            dict[NSUnderlyingErrorKey] = error;
        }
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    
    return _managedObjectContext;
}

#pragma mark - Core Data Saving and Undo support

//- (IBAction)saveAction:(id)sender {
//    // Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
//    NSManagedObjectContext *context = self.managedObjectContext;
//    
//    if (![context commitEditing]) {
//        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
//    }
//    
//    NSError *error = nil;
//    if (context.hasChanges && ![context save:&error]) {
//        [[NSApplication sharedApplication] presentError:error];
//    }
//}



+ (NSManagedObjectContext *)newMOC
{
    if ([NSThread isMainThread]) {
        return [[DB sharedInstance] managedObjectContext];
    }
    
    NSPersistentStoreCoordinator *persistentStoreCoordinator= [[DB sharedInstance]persistentStoreCoordinator];
    NSManagedObjectContext  *result = nil;
    
    result = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [result setPersistentStoreCoordinator:persistentStoreCoordinator];
    [result setMergePolicy:NSMergeByPropertyStoreTrumpMergePolicy];
    return result;
}

+(NSArray*)queryWithEntity:(NSString*)entityName andPredicate:(NSPredicate*)_predicate moc:(NSManagedObjectContext*)moc{
    NSLog(@"%@", _predicate);
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:moc];
    NSFetchRequest *request = [NSFetchRequest new];
    [request setEntity:entity];
    
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



+(void)removeObjects:(NSArray*)list moc:(NSManagedObjectContext*)moc
{
    if (list) {
        for (NSManagedObject*item in list) {
            [moc deleteObject:item];
        }
        [DB saveContext:moc];
    }
}

//+(void)deleteItemsEntity:(NSString*)entityName andPredicate:(NSPredicate*)_predicate moc:(NSManagedObjectContext*)moc
//{
//    NSArray *list = [DBManager queryWithEntity:entityName andPredicate:_predicate moc:moc];
//    for(NSManagedObject* dummy in list) {
//        [moc deleteObject:dummy];
//    }
//    [moc save:nil];
//}


+ (void)saveContext:(NSManagedObjectContext *)managedObjectContext
{
    NSError *error = nil;
    if ([managedObjectContext hasChanges] && [managedObjectContext save:&error]) {
        NSLog(@"CORE saveContext YES");
    }
    if (error!=nil) {
        NSLog(@"CORE saveContext NO with error: %@, %@", error, [error userInfo]);
    }
}



+(void)resetAllEntities:(NSString *)nameEntity inMoc:(NSManagedObjectContext*)moc
{
    [DB resetEntities:nameEntity inMoc:moc predicate:nil];
}

+(void)resetEntities:(NSString *)nameEntity inMoc:(NSManagedObjectContext*)moc predicate:(NSPredicate*)predicate
{
    NSManagedObjectContext * _moc=moc;
    if (!_moc) {
        _moc =[DB newMOC];
    }
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:nameEntity];
    [fetchRequest setIncludesPropertyValues:NO];
    if (predicate) {
        [fetchRequest setPredicate:predicate];
    }
    NSError *error;
    NSArray *fetchedObjects = [moc executeFetchRequest:fetchRequest error:&error];
    for (NSManagedObject *object in fetchedObjects)
    {
        [moc deleteObject:object];
    }
    error = nil;
    [moc save:&error];
}

+(void)killDB{
    NSManagedObjectContext * moc =[DB newMOC];
    NSArray*list = @[NSStringFromClass([KeyBind class]),
                     NSStringFromClass([RunScript class])
                     ];
    for (NSString* item in list) {
        [DB resetAllEntities:item inMoc:moc];
    }
    [DB saveContext:moc];
}

//========================================================
+(NSArray*)getKeyBinds{
    NSManagedObjectContext *moc = [DB newMOC];
    NSFetchRequest *request = [KeyBind fetchRequest];
    
    NSError *error = nil;
    NSArray *results = [moc executeFetchRequest:request error:&error];
    return results;
}

+(NSArray*)getKeyBindsWithPredicate:(NSPredicate*)filter{
    NSManagedObjectContext *moc = [DB newMOC];
    return [KeyBind queryWithPredicate:filter moc:moc];
}




+(void)addDemo{
    NSManagedObjectContext *moc = [DB newMOC];
    KeyBind *kb =  [KeyBind newObjectWithMOC:moc];
//    [NSEntityDescription insertNewObjectForEntityForName:@"KeyBind" inManagedObjectContext: moc];
    kb.isAlt = YES;
    kb.keyCode = 18;
    kb.title = @"Demo";
    RunScript *rs = [RunScript newObjectWithMOC:moc];
    rs.cmd =  @"display notification \"Pressed ALT+1\" with title \"Hi from AppleScript!\"";
//    rs.keyBind = kb;
    kb.runScript = rs;
    [moc save:nil];
}
@end
