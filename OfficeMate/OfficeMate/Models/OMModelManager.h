//
//  OMModelManager.h
//  OfficeMate
//
//  Created by Himadri Jyoti on 23/05/15.
//  Copyright (c) 2015 Ravindra Shetty. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OMUser;

@interface OMModelManager : NSObject

+ (OMModelManager *)sharedManager;
- (void)initializeBeaconStac;

@property (nonatomic, strong, readonly) OMUser *currentUser;


@end
