//
//  LazyParseArray.m
//  m7background
//
//  Created by dev on 1/20/14.
//  Copyright (c) 2014 dev. All rights reserved.
//

#import "LazyParseArray.h"

@interface LazyParseArray ()
{
    NSUInteger counter;
}

@end

@implementation LazyParseArray

- initWithClassName:(NSString*)className finishedCountingHandler:(void (^)())handler
{
    if([super init])
    {
        self.className = className;
        self.alreadyVisited = [NSMutableDictionary new];
        counter = 0;
        PFQuery *query = [PFQuery queryWithClassName:self.className];
        [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
            counter = number;
            if(handler)
                handler();
        }];
    }
    return self;
}

- (NSUInteger)count
{
    return counter;
}

- (PFObject*)objectAtIndex:(NSUInteger)index
{
    NSNumber *key = [NSNumber numberWithUnsignedInteger:index];
    PFObject *obj = [self.alreadyVisited objectForKey:key];
    if(!obj)
    {
        PFQuery *query = [PFQuery queryWithClassName:self.className];
        [query orderByAscending:@"createdAt"];
        query.limit = 1;
        query.skip = index;
        obj = [query findObjects][0];
        [self.alreadyVisited setObject:obj forKey:key];
    }
    return obj;
}

@end
