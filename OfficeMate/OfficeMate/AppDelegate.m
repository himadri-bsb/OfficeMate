//
//  AppDelegate.m
//  OfficeMate
//
//  Created by Ravindra Shetty on 23/05/15.
//  Copyright (c) 2015 Ravindra Shetty. All rights reserved.
//

#import "AppDelegate.h"
#import <Fabric/Fabric.h>
#import <DigitsKit/DigitsKit.h>
#import <Parse/Parse.h>
#import "OMAppearance.h"
#import "OMModelManager.h"
#import "OMUser.h"
#import "OMCommonDefs.h"
#import "SVProgressHUD.h"

@interface AppDelegate () <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;

@end

@implementation AppDelegate


+ (AppDelegate *)sharedAppDelegate
{
    return  (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)showLoader:(BOOL)show {
    if (show) {
        [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.9]];
        [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
        [SVProgressHUD show];
    }
    else {
        [SVProgressHUD dismiss];
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    //Digits
    [Fabric with:@[DigitsKit]];

    //Parse
    [Parse setApplicationId:@"dv11KZfycI8fr3pIFaJYIzoS0kvxxVVfARjko9oy"
                  clientKey:@"lJLHnb0K81fxhWQ7hexYIIlLLGEiCH1r0qlIZvnw"];
    //[PFUser enableRevocableSessionInBackground];

    [[OMModelManager sharedManager] initializeBeaconStac];

    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
    
    if ([PFUser currentUser]) {
        [self showHomescreenWithAnimation:NO];
    }
    else {
        //Show signin
        [self showSignInScreen];
    }
    
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                    UIUserNotificationTypeBadge |
                                                    UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                             categories:nil];
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];
    
    return YES;
}

- (void)showSignInScreen {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *signInViewController = [storyboard instantiateViewControllerWithIdentifier:@"signupScreen"];
    self.window.rootViewController = signInViewController;
}

- (void)showHomescreenWithAnimation:(BOOL)animated {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"HomeStoryBoard" bundle:nil];
    UITabBarController *homeTabBarController = [storyboard instantiateViewControllerWithIdentifier:@"homeTabbar"];
    if (animated) {
        UIView *snapShot = [self.window snapshotViewAfterScreenUpdates:YES];
        [homeTabBarController.view addSubview:snapShot];
        self.window.rootViewController = homeTabBarController;
        [UIView animateWithDuration:0.3 animations:^{
            snapShot.layer.opacity = 0;
        } completion:^(BOOL finished) {
            [snapShot removeFromSuperview];
        }];
    }
    else {
        self.window.rootViewController = homeTabBarController;
    }
}

- (void)handleSignUpCompletion {
    [self showHomescreenWithAnimation:YES];}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if ([PFUser currentUser]) {
        //save the installation
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        currentInstallation[INSTALLATION_USER_ID] = [[PFUser currentUser] objectId];
        // here we add a column to the installation table and store the current user’s ID
        // this way we can target specific users later

        // while we’re at it, this is a good place to reset our app’s badge count
        // you have to do this locally as well as on the parse server by updating
        // the PFInstallation object
        if (currentInstallation.badge != 0) {
            currentInstallation.badge = 0;
            [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error) {
                    NSLog(@"Error is saving installation");
                }
                else {
                    // only update locally if the remote update succeeded so they always match
                    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
                    NSLog(@"updated badge");
                }
            }];
        }
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    currentInstallation.channels = @[ @"global" ];
    [currentInstallation saveInBackground];
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region {

}

@end
