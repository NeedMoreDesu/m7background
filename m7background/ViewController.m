//
//  ViewController.m
//  m7background
//
//  Created by dev on 1/17/14.
//  Copyright (c) 2014 dev. All rights reserved.
//

#import "ViewController.h"
#import <CoreMotion/CoreMotion.h>
#import <Parse/Parse.h>

@interface ViewController ()
{
    int _totalSteps;
    __block ViewController *blockSelf;
}

@property CMStepCounter *stepCounter;
@property CMMotionManager *motionManager;
@property CMMotionActivityManager *motionActivityManager;

@property NSNumber *motionManagerUseCount;

@property (nonatomic) NSOperationQueue *operationQueue;

@property (weak, nonatomic) IBOutlet UILabel *stepsCountingLabel;
@property (weak, nonatomic) IBOutlet UILabel *motionLabel;
@property (weak, nonatomic) IBOutlet UILabel *motionActivityLabel;


@end

@implementation ViewController

- (NSOperationQueue *)operationQueue
{
    if (_operationQueue == nil)
    {
        _operationQueue = [NSOperationQueue new];
    }
    return _operationQueue;
}

-(NSString*)formatWithMotion:(CMDeviceMotion*)motion
                    useCount:(NSNumber*)useCount
{
    return [NSString stringWithFormat:
            @"%@"
            @"rotationXYZ: %.3f %.3f %.3f\n"
            @"gravityXYZ: %.3f %.3f %.3f\n"
            @"accelerationXYZ: %.3f %.3f %.3f\n"
            @"magneticXYZ: %.3f %.3f %.3f\n"
            @"count: %d",
            motion.attitude,
            motion.rotationRate.x,
            motion.rotationRate.y,
            motion.rotationRate.z,
            motion.gravity.x,
            motion.gravity.y,
            motion.gravity.z,
            motion.userAcceleration.x,
            motion.userAcceleration.y,
            motion.userAcceleration.z,
            motion.magneticField.field.x,
            motion.magneticField.field.y,
            motion.magneticField.field.z,
            useCount.intValue];
}

-(NSString*)formatWithMotionActivity:(CMMotionActivity*)activity
{
    return [NSString stringWithFormat:
            @"stationary: %hhd\n"
            "walking: %hhd\n"
            "running %hhd\n"
            "automotive %hhd\n"
            "unknown %hhd\n"
            "startDate %@\n"
            "confidence %d",
            activity.stationary,
            activity.walking,
            activity.running,
            activity.automotive,
            activity.unknown,
            activity.startDate,
            activity.confidence];
}

-(void)sendToParseWithClassName:(NSString*)className
                     dictionary:(NSDictionary*)dictionary
{
    PFObject *pfobject = [PFObject objectWithClassName:className];
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        pfobject[key] = obj;
    }];
    [pfobject saveInBackground];
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    blockSelf = self;
    _totalSteps = 0;
    self.motionManagerUseCount = @0;
    
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.deviceMotionUpdateInterval = 1.0;
    
//    for (int i = 0; i<30; i++) {
//        [self
//         sendToParseWithClassName:[@{@1:@"Motion", @2:@"MotionActivity", @3:@"Steps"}
//                                   objectForKey:[NSNumber numberWithInt:1+arc4random_uniform(3)]]
//         dictionary:@{@"string":[NSString stringWithFormat:@"random:%u", arc4random_uniform(42)]}];
//    }
    
    [self.motionManager
     startDeviceMotionUpdatesToQueue:self.operationQueue
     withHandler:^(CMDeviceMotion *motion, NSError *error) {
         [[NSOperationQueue mainQueue] addOperationWithBlock:^{
             NSString *formattedString = [blockSelf
                                          formatWithMotion:motion
                                          useCount:blockSelf.motionManagerUseCount];
             blockSelf.motionLabel.text = formattedString;
             [blockSelf
              sendToParseWithClassName:@"Motion"
              dictionary:@{@"string":formattedString}];
         }];
     }];
    if ([CMMotionActivityManager isActivityAvailable])
    {
        self.motionActivityManager = [[CMMotionActivityManager alloc] init];
        [self.motionActivityManager
         startActivityUpdatesToQueue:self.operationQueue
         withHandler:^(CMMotionActivity *activity) {
             [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                 NSString *formattedString = [blockSelf
                                              formatWithMotionActivity:activity];
                 blockSelf.motionActivityLabel.text = formattedString;
                 [blockSelf
                  sendToParseWithClassName:@"MotionActivity"
                  dictionary:@{@"string":formattedString}];
             }];
         }];
    }
    
    if ([CMStepCounter isStepCountingAvailable])
    {
        self.stepCounter = [[CMStepCounter alloc] init];
        [self.stepCounter
         startStepCountingUpdatesToQueue:self.operationQueue
         updateOn:1
         withHandler:^(NSInteger numberOfSteps, NSDate *timestamp, NSError *error)
         {
             [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                 _totalSteps += numberOfSteps;
                 NSString *formattedString = [NSString stringWithFormat:@"Steps: %ld, Total steps: %d", (long)numberOfSteps, _totalSteps];
                 blockSelf.motionActivityLabel.text = formattedString;
                 [blockSelf
                  sendToParseWithClassName:@"Steps"
                  dictionary:@{@"string":formattedString}];
             }];
         }];
    }
    
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
