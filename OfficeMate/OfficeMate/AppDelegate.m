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

@interface AppDelegate () <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;

@end

@implementation AppDelegate


+ (AppDelegate *)sharedAppDelegate
{
    return  (AppDelegate *)[[UIApplication sharedApplication] delegate];
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
        [self showHomescreen];
    }
    else {
        //Show signin
        [self showSignInScreen];
    }
    
    return YES;
}

- (void)showSignInScreen {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *signInNavController = [storyboard instantiateViewControllerWithIdentifier:@"signInNavScreen"];
    self.window.rootViewController = signInNavController;
}

- (void)showHomescreen {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"HomeStoryBoard" bundle:nil];
    UITabBarController *homeTabBarController = [storyboard instantiateViewControllerWithIdentifier:@"homeTabbar"];
    self.window.rootViewController = homeTabBarController;
}

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
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region {

}

@end
