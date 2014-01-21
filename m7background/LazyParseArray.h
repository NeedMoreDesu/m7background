//
//  LazyParseArray.h
//  m7background
//
//  Created by dev on 1/20/14.
//  Copyright (c) 2014 dev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface LazyParseArray : NSObject

@property NSString *className;
@property NSMutableDictionary *alreadyVisited;

- initWithClassName:(NSString*)className finishedCountingHandler:(void (^)())handler;

- (PFObject*)objectAtIndex:(NSUInteger)index;
- (NSUInteger)count;
- (NSUInteger)updateAndReturnCounter;

@end
