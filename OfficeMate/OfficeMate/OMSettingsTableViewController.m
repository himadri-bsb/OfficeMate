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
#import "AppDelegate.h"
#import "OMCommonDefs.h"

@interface OMSettingsTableViewController ()<UIPickerViewDataSource, UIPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *nameField;
@property (weak, nonatomic) IBOutlet UILabel *phonenumberLable;
@property (nonatomic, strong) UIPickerView *durationPickerView;
@property (nonatomic, retain) NSArray *pickerViewDataSource;

@end

@implementation OMSettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self loadUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSDictionary *alertValue = [[NSUserDefaults standardUserDefaults] valueForKey:kWalkAlertKey];
    [self resetAlertDurationCellWithValue:alertValue];
}

- (void)loadUI {
    OMUser *currentUser = [[OMModelManager sharedManager] currentUser];
    self.nameField.text = currentUser.userName;
    self.phonenumberLable.text = currentUser.phoneNumber;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        [self showPickerView];
    }
}

- (void)showPickerView {
    if (!self.durationPickerView) {
        self.durationPickerView = [[UIPickerView alloc] init];
        self.durationPickerView.dataSource = self;
        self.durationPickerView.delegate = self;
        [self.durationPickerView setFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds), CGRectGetWidth(self.view.bounds), 216.0)];
        [self.durationPickerView setBackgroundColor:[UIColor whiteColor]];
        [[AppDelegate sharedAppDelegate].window addSubview:self.durationPickerView];
    }
    [self showPicker:YES];
    
    NSDictionary *alertValue = [[NSUserDefaults standardUserDefaults] valueForKey:kWalkAlertKey];
    if (!alertValue) {
        [self.durationPickerView selectRow:0 inComponent:0 animated:NO];
    }
    else {
        [self.durationPickerView selectRow:[self.pickerViewDataSource indexOfObject:alertValue] inComponent:0 animated:NO];
    }
}

- (void)showPicker:(BOOL)show {
    CGRect finalRect = self.durationPickerView.frame;
    if (show) {
        finalRect.origin.y= CGRectGetHeight(self.view.bounds)-CGRectGetHeight(finalRect);
    }
    else {
        finalRect.origin.y = CGRectGetHeight(self.view.bounds);
    }
    [UIView animateWithDuration:0.3f animations:^{
        [self.durationPickerView setFrame:finalRect];
    }];
}

- (NSArray *)pickerViewDataSource {
    if (!_pickerViewDataSource) {
        _pickerViewDataSource = @[@{@"Off":@"0"},
                                  @{@"10 seconds":@"0.167"},
                                  @{@"5 mins":@"5"},
                                  @{@"30 mins":@"30"},
                                  @{@"45 mins":@"45"},
                                  @{@"1 Hour":@"60"},
                                  @{@"1.5 Hours":@"90"},
                                  @{@"2 Hours":@"120"}];
    }
    return _pickerViewDataSource;
}


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.pickerViewDataSource count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [[[self.pickerViewDataSource  objectAtIndex:row] allKeys] firstObject];
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [self resetAlertDurationCellWithValue:[self.pickerViewDataSource  objectAtIndex:row]];
    [self showPicker:NO];
}

- (void)resetAlertDurationCellWithValue:(NSDictionary *)dictionary {
    if (!dictionary) {
        dictionary = @{@"Off":@"0"};
    }
    [[NSUserDefaults standardUserDefaults] setObject:dictionary forKey:kWalkAlertKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSString *optionString = [[dictionary allKeys] firstObject];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [cell.detailTextLabel setText:optionString];
    if ([optionString isEqualToString:@"Off"]) {
        [cell.textLabel setTextColor:[UIColor blackColor]];
        [cell.detailTextLabel setTextColor:[UIColor blackColor]];
    }
    else {
        [cell.textLabel setTextColor:[OMAppearance appThemeColorWithAlpha:1.0f]];
        [cell.detailTextLabel setTextColor:[OMAppearance appThemeColorWithAlpha:1.0f]];
        [[AppDelegate sharedAppDelegate] scheduleLocalNNotification];
    }
}

@end
