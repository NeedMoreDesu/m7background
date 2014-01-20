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
    int _handlerUsedCount;
}

@property CMStepCounter *stepCounter;
@property CMMotionManager *motionManager;
@property CMMotionActivityManager *motionActivityManager;

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


- (void)viewDidLoad
{
    [super viewDidLoad];
    _totalSteps = 0;
    _handlerUsedCount = 0;
    
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.deviceMotionUpdateInterval = 1.0;
    
    [self.motionManager
     startDeviceMotionUpdatesToQueue:self.operationQueue
     withHandler:^(CMDeviceMotion *motion, NSError *error) {
         [[NSOperationQueue mainQueue] addOperationWithBlock:^{
             PFObject *motionObject = [PFObject objectWithClassName:@"Motion"];
             _handlerUsedCount++;
             self.motionLabel.text = [NSString stringWithFormat:
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
                                      _handlerUsedCount];
             motionObject[@"string"] = self.motionLabel.text;
             [motionObject saveInBackground];
         }];
     }];
    
    if ([CMMotionActivityManager isActivityAvailable])
    {
        self.motionActivityManager = [[CMMotionActivityManager alloc] init];
        [self.motionActivityManager
         startActivityUpdatesToQueue:self.operationQueue
         withHandler:^(CMMotionActivity *activity) {
             [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                 PFObject *motionActivityObject = [PFObject objectWithClassName:@"MotionActivity"];
                 self.motionActivityLabel.text = [NSString stringWithFormat:
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
                 motionActivityObject[@"string"] = self.motionActivityLabel.text;
                 [motionActivityObject saveInBackground];
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
                 PFObject *stepObject = [PFObject objectWithClassName:@"Step"];
                 _totalSteps += numberOfSteps;
                 self.stepsCountingLabel.text = [NSString stringWithFormat:@"Steps: %ld, Total steps: %d", (long)numberOfSteps, _totalSteps];
                 stepObject[@"string"] = self.stepsCountingLabel.text;
                 [stepObject saveInBackground];
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
