//
//  OMHomeScreenViewControllerTableViewController.m
//  OfficeMate
//
//  Created by Ravindra Shetty on 23/05/15.
//  Copyright (c) 2015 Ravindra Shetty. All rights reserved.
//

#import "OMHomeTableViewController.h"
#import "OMHomeTableViewCell.h"
#import "OMAppearance.h"
#import "OMCommonDefs.h"
#import "OMUser.h"
#import "OMModelManager.h"
#import <Parse/Parse.h>

@interface OMHomeTableViewController ()<UIActionSheetDelegate>
@property (nonatomic, strong) NSMutableArray *usersArray;
@property (nonatomic, assign) OMHomeTableViewCell *tappedCell;
@end

@implementation OMHomeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barTintColor = [OMAppearance appThemeColorWithAlpha:1];
    self.navigationController.navigationBar.tintColor = [OMAppearance appBgColorWithAlpha:1];
    [self setNeedsStatusBarAppearanceUpdate];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLongPressForCell:) name:kNotification_LongPressTableCell object:nil];

    
    [self refreshData];
}

- (void)handleLongPressForCell:(NSNotification  *)notification {
    self.tappedCell = notification.object;
    if ([self.tappedCell.locationInfoLabel.text isEqualToString:UNKNOWN_LOCATION] && !self.tappedCell.isObserving) {
        UIActionSheet *actionsheet = [[UIActionSheet alloc] initWithTitle:@"Notify?" delegate:self cancelButtonTitle:@"No" destructiveButtonTitle:nil otherButtonTitles:@"Yes", nil];
        [actionsheet showInView:self.view];
    }
    else {
        UIActionSheet *actionsheet = [[UIActionSheet alloc] initWithTitle:@"Remove Observer?" delegate:self cancelButtonTitle:@"No" destructiveButtonTitle:nil otherButtonTitles:@"Yes", nil];
        [actionsheet showInView:self.view];
    }
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != [actionSheet cancelButtonIndex]) {
        if (self.tappedCell.isObserving) {
            self.tappedCell.isObserving = NO;
            self.tappedCell.observingIndicator.hidden = YES;
        }
        else {
            self.tappedCell.isObserving = YES;
            self.tappedCell.observingIndicator.hidden = NO;
        }
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.usersArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OMHomeTableViewCell *cell = (OMHomeTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"homeCell" forIndexPath:indexPath];
    PFUser *parseUser = [self.usersArray objectAtIndex:indexPath.row];
    NSAssert([parseUser isKindOfClass:[PFUser class]], @"Inavlid object in cellForRowAtIndexPath");
    
    OMUser *user = [[OMUser alloc] initWithPFUser:parseUser];
    
    cell.userInfoLabel.text =[NSString stringWithFormat:@"%@  (%@)",user.userName, user.phoneNumber];
    cell.locationInfoLabel.text = user.location;
    if (cell.isObserving) {
        cell.observingIndicator.hidden = NO;
    }
    else {
        cell.observingIndicator.hidden = YES;
    }
    return cell;
}




- (void)refreshData {
    OMUser *currentUser = [[OMModelManager sharedManager] currentUser];
    PFQuery *query = [PFUser query];
    [query whereKey:@"username" notEqualTo:currentUser.parseUser.username];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error) {
                // The find succeeded. The first 100 objects are available in objects
                NSLog(@"%@", objects);
                self.usersArray = [NSMutableArray arrayWithArray:objects];
                [self.tableView reloadData];
            } else {
                // Log details of the failure
                //NSLog(@"Error: %@ %@", error, [error userInfo]);
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Refresh Error" message:[NSString stringWithFormat:@"Error = %@",error] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alertView show];
            }
        });
    }];
}

- (IBAction)refreshAction:(id)sender {
    [self refreshData];


    /*
    [PFCloud callFunctionInBackground:@"hello"
                       withParameters:@{}
                                block:^(NSString *result, NSError *error) {
                                    if (!error) {
                                        // result is @"Hello world!"
                                    }
                                }];
     
     */
}

@end
