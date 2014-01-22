//
//  Gravity.h
//  m7background
//
//  Created by dev on 1/22/14.
//  Copyright (c) 2014 dev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Gravity : NSManagedObject

@property (nonatomic, retain) NSNumber * x;
@property (nonatomic, retain) NSNumber * y;
@property (nonatomic, retain) NSNumber * z;
@property (nonatomic, retain) NSManagedObject *motion;

@end
