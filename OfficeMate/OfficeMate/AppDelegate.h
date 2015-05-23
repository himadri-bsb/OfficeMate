//
//  AppDelegate.h
//  OfficeMate
//
//  Created by Ravindra Shetty on 23/05/15.
//  Copyright (c) 2015 Ravindra Shetty. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

+ (AppDelegate *)sharedAppDelegate;
- (void)showLoader:(BOOL)show;
- (void)handleSignUpCompletion;
- (void)scheduleLocalNNotification;
- (void)cancelNotificationNotification;
@end

