//
//  Motion.h
//  m7background
//
//  Created by dev on 1/22/14.
//  Copyright (c) 2014 dev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Gravity, MagneticField, Rotation, UserAcceleration;

@interface Motion : NSManagedObject

@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSString * string;
@property (nonatomic, retain) Gravity *gravity;
@property (nonatomic, retain) MagneticField *magneticField;
@property (nonatomic, retain) Rotation *rotation;
@property (nonatomic, retain) UserAcceleration *userAcceleration;

@end
