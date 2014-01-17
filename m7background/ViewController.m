//
//  ViewController.m
//  m7background
//
//  Created by dev on 1/17/14.
//  Copyright (c) 2014 dev. All rights reserved.
//

#import "ViewController.h"
#import <CoreMotion/CoreMotion.h>

@interface ViewController ()
{
    int _totalSteps;
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
    
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.deviceMotionUpdateInterval = 1.0;
    [self.motionManager
     startDeviceMotionUpdatesToQueue:self.operationQueue
     withHandler:^(CMDeviceMotion *motion, NSError *error) {
         [[NSOperationQueue mainQueue] addOperationWithBlock:^{
             self.motionLabel.text = [NSString stringWithFormat:@"attitude: %@",
                                      motion.attitude];
         }];
     }];
    
    [self.motionActivityManager
     startActivityUpdatesToQueue:self.operationQueue
     withHandler:^(CMMotionActivity *activity) {
         [[NSOperationQueue mainQueue] addOperationWithBlock:^{
             self.motionActivityLabel.text = [NSString stringWithFormat:
                                              @"stationary: %hhd, "
                                              "walking: %hhd, "
                                              "running %hhd, "
                                              "automotive %hhd, "
                                              "unknown %hhd, "
                                              "startDate %@, "
                                              "confidence %d",
                                              activity.stationary,
                                              activity.walking,
                                              activity.running,
                                              activity.automotive,
                                              activity.unknown,
                                              activity.startDate,
                                              activity.confidence];
         }];
     }];
    
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
                 self.stepsCountingLabel.text = [NSString stringWithFormat:@"Steps: %ld, Total steps: %d", (long)numberOfSteps, _totalSteps];
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
