//
//  OMUser.h
//  OfficeMate
//
//  Created by Himadri Jyoti on 23/05/15.
//  Copyright (c) 2015 Ravindra Shetty. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

extern NSString * const USER_PHONE_NO;

@interface OMUser : NSObject

- (instancetype)initWithPFUser:(PFUser*)parseUser;

@property (nonatomic, readonly)PFUser *parseUser;

@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *phoneNumber;
@property (nonatomic, copy) NSString *location;

@end
