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
#import "OMCommonDefs.h"

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
        PFUser *parseUser = [PFUser currentUser];
        if (!parseUser) {
            parseUser = [PFUser user];
        }
        self.currentUser = [[OMUser alloc] initWithPFUser:parseUser];
    }

    return self;
}

- (void)initializeBeaconStac {
    [[MSLogger sharedInstance]setLoglevel:MSLogLevelNone];

    /*
     * Setup and initialize the Beaconstac SDK
     */
    self.beaconstac = [Beaconstac sharedInstanceWithOrganizationId:83 developerToken:@"295acec3758b467ab89d78e0024bf9401dc31b78"];
    [self.beaconstac startRangingBeaconsWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D" beaconIdentifier:@"com.bsb.officemate" filterOptions:nil];
    self.beaconstac.beaconaffinity = MSBeaconAffinityLow;

    /*
     * End of Beaconstac SDK init
     */

    [self.beaconstac setDelegate:self];
}

#pragma mark - Beaconstac delegate
// Tells the delegate a list of beacons in range.
- (void)beaconstac:(Beaconstac *)beaconstac rangedBeacons:(NSDictionary *)beaconsDictionary {
    //NSLog(@"beaconstac:rangedBeacons");
}

// Tells the delegate that GPS location has been updated.
- (void)beaconstac:(Beaconstac *)beaconstac didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    //NSLog(@"beaconstac:didUpdateToLocation");
}

// Tells the delegate about the camped on beacon among available beacons.
- (void)beaconstac:(Beaconstac*)beaconstac campedOnBeacon:(MSBeacon*)beacon amongstAvailableBeacons:(NSDictionary *)beaconsDictionary {
    NSLog(@"campedOnBeacon: %@", beacon.beaconKey);

    OMUser *currentUser = [[OMModelManager sharedManager] currentUser];
    if(![PFUser currentUser]) {
        //User not signed in
        return;
    }
    MSBeacon *campedBeacon = (MSBeacon*)beacon;
    NSString *location = [[campedBeacon.beaconKey uppercaseString] stringByReplacingOccurrencesOfString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D:" withString:@""];
    NSString *exactLocation = UNKNOWN_LOCATION;
    if([location isEqualToString:@"6616:56252"]) {
        exactLocation = @"Cafeteria";
        NSLog(@"Camped on CAFE");
    }
    else if([location isEqualToString:@"49201:35267"]){
        exactLocation = @"Desk";
        NSLog(@"Camped on DESK");
    }



    if(![currentUser.location isEqualToString:exactLocation]) {
        NSString *oldLocation = currentUser.location;
        currentUser.location = exactLocation;

        if([oldLocation isEqualToString:UNKNOWN_LOCATION] && ![exactLocation isEqualToString:UNKNOWN_LOCATION]) {
            //This might be the case of sending push notification
            PFQuery *query = [PFQuery queryWithClassName:TRIGGER_CLASS_NAME];
            [query whereKey:TRIGGER_SENDER equalTo:[[[OMModelManager sharedManager] currentUser] phoneNumber]];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                for (PFObject *object in objects) {
                    if([object[TRIGGER_ISSET] isEqualToString:YES_STRING]) {
                        [self sendPushToMsisdn:[object[TRIGGER_OBSERVER] copy] location:exactLocation];
                        [object deleteInBackground];
                    }
                }
            }];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDidUserChangedLocation object:nil];
        }

        [currentUser.parseUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if(error) {
                NSLog(@"beaconstac: campedOnBeacon: ERROR on saving location, error = %@",error);
            }
        }];
    }
}

// Tells the delegate when the device exits from the camped on beacon range.
- (void)beaconstac:(Beaconstac*)beaconstac exitedBeacon:(MSBeacon*)beacon {
    NSLog(@"exitedBeacon: %@", beacon.beaconKey);

    OMUser *currentUser = [[OMModelManager sharedManager] currentUser];
    if(![PFUser currentUser]) {
        //User not signed in
        return;
    }

    MSBeacon *campedBeacon = (MSBeacon*)beacon;
    NSString *location = [[campedBeacon.beaconKey uppercaseString] stringByReplacingOccurrencesOfString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D:" withString:@""];
    NSString *exactLocation = UNKNOWN_LOCATION;
    if([location isEqualToString:@"6616:56252"]) {
        exactLocation = @"Cafeteria";
        NSLog(@"Exited on CAFE");
    }
    else if([location isEqualToString:@"49201:35267"]){
        exactLocation = @"Desk";
        NSLog(@"Exited on DESK");
    }



    if(![currentUser.location isEqualToString:UNKNOWN_LOCATION]) {
        currentUser.location = UNKNOWN_LOCATION;

        [currentUser.parseUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if(error) {
                NSLog(@"beaconstac: exitedBeacon: ERROR on saving location, error = %@",error);
            }

        }];
    }
}

// Tells the delegate when the device has entered a beacon region
- (void)beaconstac:(Beaconstac*)beaconstac didEnterBeaconRegion:(CLRegion*)region {
    //NSLog(@"DemoApp:Entered beacon region :%@", region.identifier);
}

// Tells the delegate when the device has exited a beacon region
- (void)beaconstac:(Beaconstac*)beaconstac didExitBeaconRegion:(CLRegion *)region {
    //NSLog(@"DemoApp:Exited beacon region :%@", region.identifier);
}

#pragma mark - Push Notification Sending
- (void)sendPushToMsisdn:(NSString*)msisdn location:(NSString*)location{
    NSString *pushText = [NSString stringWithFormat:@"%@ is near %@ now!", [[[OMModelManager sharedManager] currentUser] userName], location];

    //Do an user query based on msisdn
    PFQuery *query = [PFUser query];
    [query whereKey:@"username" equalTo:msisdn];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        PFUser *user = [objects lastObject];
        if(user) {
            PFQuery *pushQuery = [PFInstallation query];
            [pushQuery whereKey:INSTALLATION_USER_ID equalTo:user.objectId];

            // Send push notification to query
            [PFPush sendPushMessageToQueryInBackground:pushQuery
                                           withMessage:pushText];
        }
    }];


}



@end
