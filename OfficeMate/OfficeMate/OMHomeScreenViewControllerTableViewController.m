//
//  OMHomeScreenViewControllerTableViewController.m
//  OfficeMate
//
//  Created by Ravindra Shetty on 23/05/15.
//  Copyright (c) 2015 Ravindra Shetty. All rights reserved.
//

#import "OMHomeScreenViewControllerTableViewController.h"
#import "OMHomeTableViewCell.h"
#import "OMAppearance.h"
#import "OMUser.h"
#import "OMModelManager.h"
#import <Parse/Parse.h>

@interface OMHomeScreenViewControllerTableViewController ()
@property (nonatomic, strong) NSMutableArray *usersArray;
@end

@implementation OMHomeScreenViewControllerTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barTintColor = [OMAppearance appThemeColorWithAlpha:1];
    self.navigationController.navigationBar.tintColor = [OMAppearance appBgColorWithAlpha:1];
    [self setNeedsStatusBarAppearanceUpdate];
    
    [self refreshData];
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
    return self.usersArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OMHomeTableViewCell *cell = (OMHomeTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"homeCell" forIndexPath:indexPath];
    cell.nameLable.text = @"Name";
    cell.timestampLabel.text = @"timestamp";
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


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

@end
