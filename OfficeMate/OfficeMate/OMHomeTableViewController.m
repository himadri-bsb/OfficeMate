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
#import "AppDelegate.h"

@implementation UITabBarController (ChildStatusBarStyle)

- (UIViewController *)childViewControllerForStatusBarStyle
{
    return [[(UINavigationController *)[self.viewControllers firstObject] viewControllers] firstObject];
}

@end


@interface OMHomeTableViewController ()<UIActionSheetDelegate>

@property (nonatomic, strong) NSMutableArray *usersArray;
@property (nonatomic, assign) OMHomeTableViewCell *tappedCell;

@end

@implementation OMHomeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLongPressForCell:) name:kNotification_LongPressTableCell object:nil];
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self refreshData];
}

- (void)handleLongPressForCell:(NSNotification  *)notification {
    self.tappedCell = notification.object;
    if ([self.tappedCell.locationInfoLabel.text isEqualToString:UNKNOWN_LOCATION]) {
        if (!self.tappedCell.isObserving) {
            UIActionSheet *actionsheet = [[UIActionSheet alloc] initWithTitle:@"Notify?" delegate:self cancelButtonTitle:@"No" destructiveButtonTitle:nil otherButtonTitles:@"Yes", nil];
            [actionsheet showInView:self.view];
        }
        else {
            UIActionSheet *actionsheet = [[UIActionSheet alloc] initWithTitle:@"Remove Observer?" delegate:self cancelButtonTitle:@"No" destructiveButtonTitle:nil otherButtonTitles:@"Yes", nil];
            [actionsheet showInView:self.view];
        }
    }
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != [actionSheet cancelButtonIndex]) {
        BOOL shouldSetTrigger = NO;
        if (self.tappedCell.isObserving) {
            self.tappedCell.isObserving = NO;
            self.tappedCell.observingIndicator.hidden = YES;
            shouldSetTrigger = NO;
        }
        else {
            self.tappedCell.isObserving = YES;
            self.tappedCell.observingIndicator.hidden = NO;
            shouldSetTrigger = YES;
        }

        NSIndexPath *path = [self.tableView indexPathForCell:self.tappedCell];
        PFUser *parseUser = [self.usersArray objectAtIndex:path.row];
        OMUser *user = [[OMUser alloc] initWithPFUser:parseUser];

        [self setLocationTriggerForUserNumber:user.phoneNumber enable:shouldSetTrigger];
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
    if ([user.phoneNumber isEqualToString:@"+919742496072"] || [user.phoneNumber isEqualToString:@"+917795189039"]) {
        cell.avatarImageView.image = [UIImage imageNamed:@"avatar_female"];
    }
    else {
        cell.avatarImageView.image = [UIImage imageNamed:@"avatar"];
    }
    if (cell.isObserving) {
        cell.observingIndicator.hidden = NO;
    }
    else {
        cell.observingIndicator.hidden = YES;
    }
    return cell;
}




- (void)refreshData {
    [[AppDelegate sharedAppDelegate] showLoader:YES];
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
            [[AppDelegate sharedAppDelegate] showLoader:NO];
        });
    }];
}

- (IBAction)refreshAction:(id)sender {
   [self refreshData];
}

- (void)setLocationTriggerForUserNumber:(NSString*)msisdn enable:(BOOL)enable {
    NSString *currentUserMsisdn = [[[OMModelManager sharedManager] currentUser] phoneNumber];
    PFQuery *query = [PFQuery queryWithClassName:TRIGGER_CLASS_NAME];
    [query whereKey:TRIGGER_OBSERVER equalTo:currentUserMsisdn];
    [query whereKey:TRIGGER_SENDER equalTo:msisdn];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        // Do something with the returned PFObject in the gameScore variable.
        if([objects count]) {
            PFObject *existingObj = [objects lastObject];
            existingObj[TRIGGER_OBSERVER] = currentUserMsisdn;
            existingObj[TRIGGER_SENDER] = msisdn;
            existingObj[TRIGGER_ISSET] = enable ? YES_STRING : NO_STRING;
            [existingObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if(!succeeded) {
                    NSLog(@"Failed to set location trigger existing object, error=%@",error);
                }
            }];
        }
        else {
            //Object doesn't exist
            PFObject *locTrigger = [PFObject objectWithClassName:TRIGGER_CLASS_NAME];
            locTrigger[TRIGGER_OBSERVER] = currentUserMsisdn;
            locTrigger[TRIGGER_SENDER] = msisdn;
            locTrigger[TRIGGER_ISSET] = enable ? YES_STRING : NO_STRING;
            [locTrigger saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if(!succeeded) {
                    NSLog(@"Failed to set location trigger new object, error=%@",error);
                }
            }];
        }
    }];
}


- (void)deleteLocationTriggerForUserNumber:(NSString*)msisdn enable:(BOOL)enable {
    PFQuery *query = [PFQuery queryWithClassName:TRIGGER_CLASS_NAME];
    [query whereKey:TRIGGER_OBSERVER equalTo:[[[OMModelManager sharedManager] currentUser] phoneNumber]];
    [query whereKey:TRIGGER_SENDER equalTo:msisdn];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        for(PFObject *object in objects) {
            [object deleteInBackground];
        }
    }];
}


@end
