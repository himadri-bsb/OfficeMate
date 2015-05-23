//
//  OMModelManager.m
//  OfficeMate
//
//  Created by Himadri Jyoti on 23/05/15.
//  Copyright (c) 2015 Ravindra Shetty. All rights reserved.
//

#import "OMModelManager.h"
#import "OMUser.h"
#import <Parse/Parse.h>
#import <Beaconstac_v_0_9_16/Beaconstac.h>

@interface  OMModelManager () <BeaconstacDelegate>

@property (nonatomic, strong) OMUser *currentUser;
@property (nonatomic, strong) Beaconstac *beaconstac;

@end

@implementation OMModelManager

+ (OMModelManager *)sharedManager {
    static OMModelManager* sharedModelManager = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        sharedModelManager = [[OMModelManager alloc] init];
    });

    return sharedModelManager;
}

-(instancetype)init {
    if(self = [super init]) {
        self.currentUser = [[OMUser alloc] initWithPFUser:[PFUser currentUser]];
    }

    return self;
}

- (void)initializeBeaconStac {
    [[MSLogger sharedInstance]setLoglevel:MSLogLevelVerbose];

    /*
     * Setup and initialize the Beaconstac SDK
     */
    self.beaconstac = [Beaconstac sharedInstanceWithOrganizationId:83 developerToken:@"295acec3758b467ab89d78e0024bf9401dc31b78"];
    [self.beaconstac startRangingBeaconsWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D" beaconIdentifier:@"com.bsb.officemate" filterOptions:nil];

    /*
     * End of Beaconstac SDK init
     */

    [self.beaconstac setDelegate:self];
}

#pragma mark - Beaconstac delegate
// Tells the delegate a list of beacons in range.
- (void)beaconstac:(Beaconstac *)beaconstac rangedBeacons:(NSDictionary *)beaconsDictionary {
    NSLog(@"");
}

// Tells the delegate that GPS location has been updated.
- (void)beaconstac:(Beaconstac *)beaconstac didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    NSLog(@"");
}

// Tells the delegate about the camped on beacon among available beacons.
- (void)beaconstac:(Beaconstac*)beaconstac campedOnBeacon:(MSBeacon*)beacon amongstAvailableBeacons:(NSDictionary *)beaconsDictionary {
    NSLog(@"DemoApp:campedOnBeacon: %@, %@", beacon.beaconKey, beaconsDictionary);

    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.alertBody = [NSString stringWithFormat:@"Camped on to Beacon: %@, %@", beacon.major, beacon.minor];
    [[UIApplication sharedApplication]presentLocalNotificationNow:notification];
}

// Tells the delegate when the device exits from the camped on beacon range.
- (void)beaconstac:(Beaconstac*)beaconstac exitedBeacon:(MSBeacon*)beacon {
    NSLog(@"DemoApp:ExitedBeacon: %@", beacon.beaconKey);
}

// Tells the delegate when the device has entered a beacon region
- (void)beaconstac:(Beaconstac*)beaconstac didEnterBeaconRegion:(CLRegion*)region {
    NSLog(@"DemoApp:Entered beacon region :%@", region.identifier);
}

// Tells the delegate when the device has exited a beacon region
- (void)beaconstac:(Beaconstac*)beaconstac didExitBeaconRegion:(CLRegion *)region {
    NSLog(@"DemoApp:Exited beacon region :%@", region.identifier);
}



@end
