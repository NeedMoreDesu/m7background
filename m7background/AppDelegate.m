//
//  AppDelegate.m
//  m7background
//
//  Created by dev on 1/17/14.
//  Copyright (c) 2014 dev. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import <CoreData/CoreData.h>
#import <RestKit/RestKit.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [Parse setApplicationId:@"0GoqMOdeSiC78S3XTLXXn4mXVkg1uSuKXgRDKv9j"
                  clientKey:@"ZHVBklaFlJEUuoplaovRiZ4GB3kdAEPJGN7UTHY4"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    
    // GET an Article and its Categories from /articles/888.json and map into Core Data entities
    // JSON looks like {"article": {"title": "My Article", "author": "Blake", "body": "Very cool!!", "categories": [{"id": 1, "name": "Core Data"]}
    NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    RKManagedObjectStore *managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];
    NSError *error = nil;
    BOOL success = RKEnsureDirectoryExistsAtPath(RKApplicationDataDirectory(), &error);
    if (! success) {
        RKLogError(@"Failed to create Application Data Directory at path '%@': %@", RKApplicationDataDirectory(), error);
    }
    NSString *path = [RKApplicationDataDirectory() stringByAppendingPathComponent:@"Store.sqlite"];
    NSPersistentStore *persistentStore = [managedObjectStore addSQLitePersistentStoreAtPath:path fromSeedDatabaseAtPath:nil withConfiguration:nil options:nil error:&error];
    if (! persistentStore) {
        RKLogError(@"Failed adding persistent store at path '%@': %@", path, error);
    }
    [managedObjectStore createManagedObjectContexts];
    
    RKEntityMapping *magneticFieldMapping = [RKEntityMapping mappingForEntityForName:@"MagneticField" inManagedObjectStore:managedObjectStore];
    [magneticFieldMapping addAttributeMappingsFromArray:@[@"x", @"y", @"z"]];
    RKEntityMapping *userAccelerationMapping = [RKEntityMapping mappingForEntityForName:@"UserAcceleration" inManagedObjectStore:managedObjectStore];
    [userAccelerationMapping addAttributeMappingsFromArray:@[@"x", @"y", @"z"]];
    RKEntityMapping *rotationMapping = [RKEntityMapping mappingForEntityForName:@"Rotation" inManagedObjectStore:managedObjectStore];
    [rotationMapping addAttributeMappingsFromArray:@[@"x", @"y", @"z"]];
    RKEntityMapping *gravityMapping = [RKEntityMapping mappingForEntityForName:@"Gravity" inManagedObjectStore:managedObjectStore];
    [gravityMapping addAttributeMappingsFromArray:@[@"x", @"y", @"z"]];

    RKEntityMapping *motionMapping = [RKEntityMapping mappingForEntityForName:@"Motion" inManagedObjectStore:managedObjectStore];
    [motionMapping addAttributeMappingsFromArray:@[@"createdAt", @"updatedAt"]];
    [motionMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"magneticField" toKeyPath:@"magneticField" withMapping:magneticFieldMapping]];
    [motionMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"userAcceleration" toKeyPath:@"userAcceleration" withMapping:userAccelerationMapping]];
    [motionMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"rotation" toKeyPath:@"rotation" withMapping:rotationMapping]];
    [motionMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"gravity" toKeyPath:@"gravity" withMapping:gravityMapping]];
    
    NSIndexSet *statusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful); // Anything in 2xx
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor
                                                responseDescriptorWithMapping:articleMapping
                                                method:RKRequestMethodAny
                                                pathPattern:@"/articles/:articleID"
                                                keyPath:@"article"
                                                statusCodes:statusCodes];
    //curl -X GET   -H "X-Parse-Application-Id: 0GoqMOdeSiC78S3XTLXXn4mXVkg1uSuKXgRDKv9j"   -H "X-Parse-REST-API-Key: 25gquitSGwmVBYrPbvdHNsVWj49HmocGeMvHyB9n"   https://api.parse.com/1/classes/Motion
    NSMutableURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://restkit.org/articles/888.json"]];
    [request setValue:@"0GoqMOdeSiC78S3XTLXXn4mXVkg1uSuKXgRDKv9j" forHTTPHeaderField:@"X-Parse-Application-Id"];
    [request setValue:@"25gquitSGwmVBYrPbvdHNsVWj49HmocGeMvHyB9n" forHTTPHeaderField:@"X-Parse-REST-API-Key"];
    [request setHTTPMethod:@"GET"];
    RKManagedObjectRequestOperation *operation = [[RKManagedObjectRequestOperation alloc]
                                                  initWithRequest:request
                                                  responseDescriptors:@[responseDescriptor]];
    operation.managedObjectContext = managedObjectStore.mainQueueManagedObjectContext;
    operation.managedObjectCache = managedObjectStore.managedObjectCache;
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        Article *article = [result firstObject];
        NSLog(@"Mapped the article: %@", article);
        NSLog(@"Mapped the category: %@", [article.categories anyObject]);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"Failed with error: %@", [error localizedDescription]);
    }];
    NSOperationQueue *operationQueue = [NSOperationQueue new];
    [operationQueue addOperation:operation];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
