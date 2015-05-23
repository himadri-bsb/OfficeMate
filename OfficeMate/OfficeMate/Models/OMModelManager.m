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

@interface  OMModelManager ()

@property (nonatomic, strong) OMUser *currentUser;

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

@end
