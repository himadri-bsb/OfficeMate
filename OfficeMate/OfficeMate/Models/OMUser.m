//
//  OMUser.m
//  OfficeMate
//
//  Created by Himadri Jyoti on 23/05/15.
//  Copyright (c) 2015 Ravindra Shetty. All rights reserved.
//

#import "OMUser.h"

static NSString * const USER_NAME_KEY = @"name";
static NSString * const USER_LOCATION_KEY = @"location";
static NSString * const USER_ID_KEY = @"userid";
NSString * const USER_PHONE_NO = @"phoneno";

@interface OMUser ()

@property (nonatomic, strong)PFUser *parseUser;

@end

@implementation OMUser

- (instancetype)initWithPFUser:(PFUser*)parseUser {
    self = [super init];
    if (self) {
        self.parseUser = parseUser;
    }
    return self;
}

 - (void)setUserName:(NSString*)Name {
     [self.parseUser setObject:Name forKey:USER_NAME_KEY];
 }

 - (NSString*)userName {
     return [self.parseUser objectForKey:USER_NAME_KEY];
 }

- (void)setUserID:(NSString*)userID {
    [self.parseUser setObject:userID forKey:USER_ID_KEY];
}

- (NSString*)userID {
    return [self.parseUser objectForKey:USER_ID_KEY];
}

- (void)setPhoneNumber:(NSString*)phoneNumber {
    [self.parseUser setObject:phoneNumber forKey:USER_PHONE_NO];
}

- (NSString*)phoneNumber {
    return [self.parseUser objectForKey:USER_PHONE_NO];
}

 - (void)setLocation:(NSString*)location {
     [self.parseUser setObject:location forKey:USER_LOCATION_KEY];
 }

 - (NSString*)location {
     return [self.parseUser objectForKey:USER_LOCATION_KEY];
 }


@end
