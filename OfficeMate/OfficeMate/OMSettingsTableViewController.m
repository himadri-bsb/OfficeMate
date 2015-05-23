//
//  OMSettingsTableViewController.m
//  OfficeMate
//
//  Created by Ravindra Shetty on 23/05/15.
//  Copyright (c) 2015 Ravindra Shetty. All rights reserved.
//

#import "OMSettingsTableViewController.h"
#import "OMUser.h"
#import "OMModelManager.h"
#import <Parse/Parse.h>
#import "OMAppearance.h"

@interface OMSettingsTableViewController ()
@property (weak, nonatomic) IBOutlet UILabel *nameField;
@property (weak, nonatomic) IBOutlet UILabel *phonenumberLable;
@property (weak, nonatomic) IBOutlet UILabel *lastseenLabel;

@end

@implementation OMSettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self loadUI];
}

- (void)loadUI {
    OMUser *currentUser = [[OMModelManager sharedManager] currentUser];
    self.nameField.text = currentUser.userName;
    self.phonenumberLable.text = currentUser.phoneNumber;
    //Have to fetch
    self.lastseenLabel.text = @"";
}

@end
