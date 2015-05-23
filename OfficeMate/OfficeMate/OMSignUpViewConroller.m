//
//  OMSignUpViewConroller.m
//  OfficeMate
//
//  Created by Ravindra Shetty on 23/05/15.
//  Copyright (c) 2015 Ravindra Shetty. All rights reserved.
//

#import "OMSignUpViewConroller.h"
#import <DigitsKit/DigitsKit.h>
#import "OMAppearance.h"
#import "AppDelegate.h"
#import "OMModelManager.h"
#import "OMUser.h"
#import <Parse/Parse.h>

@interface OMSignUpViewConroller () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (nonatomic, retain) DGTAuthenticateButton *phoneNumberButton;
@end

@implementation OMSignUpViewConroller

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    UITapGestureRecognizer *tapGestureRecognizer=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

- (void)setupView {
    self.navigationController.navigationBar.barTintColor = [OMAppearance appThemeColorWithAlpha:1];
    self.navigationController.navigationBar.tintColor = [OMAppearance appBgColorWithAlpha:1];
    self.nameTextField.delegate = self;
    self.nameTextField.font = [OMAppearance appFontWithSize:16 shouldBold:NO];
    [self setUpDigitButton];
}

- (void)setUpDigitButton {
    DGTAuthenticateButton *authenticateButton = [DGTAuthenticateButton buttonWithAuthenticationCompletion:^(DGTSession *session, NSError *error) {
        if(!error) {
            // Show loader
            dispatch_async(dispatch_get_main_queue(), ^{
                [[AppDelegate sharedAppDelegate] showLoader:YES];
            });
            OMUser *currentUser = [[OMModelManager sharedManager] currentUser];
            currentUser.parseUser.username = session.phoneNumber;
            currentUser.parseUser.password = session.userID;
            //Handle Parse login
            [currentUser.parseUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSLog(@"Registration success!");
                        currentUser.phoneNumber = session.phoneNumber;
                        currentUser.userName = self.nameTextField.text;
                        currentUser.userID = session.userID;

                        [currentUser.parseUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            dispatch_async(dispatch_get_main_queue(), ^ {
                                if(succeeded) {
                                    [[AppDelegate sharedAppDelegate] showLoader:NO];
                                    [[AppDelegate sharedAppDelegate] handleSignUpCompletion];
                                }
                                else {
                                    if(error) {
                                        NSLog(@"setUpDigitButton error on saving daya, error = %@",error);
                                    }
                                }
                            });
                        }];
                    });
                }
                else {
                    //Signup failed, try logging in
                    [PFUser logInWithUsernameInBackground:session.phoneNumber
                                                                password:session.userID
                                                                   block:^(PFUser *user, NSError *error) {
                        if(user) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                NSLog(@"Registration success!");
                                currentUser.parseUser = user;
                                currentUser.phoneNumber = session.phoneNumber;
                                currentUser.userName = self.nameTextField.text;
                                currentUser.userID = session.userID;


                                [currentUser.parseUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                    dispatch_async(dispatch_get_main_queue(), ^ {
                                        if(succeeded) {
                                            [[AppDelegate sharedAppDelegate] handleSignUpCompletion];
                                        }
                                        else {
                                            if(error) {
                                                NSLog(@"setUpDigitButton error on saving daya, error = %@",error);
                                            }
                                        }
                                    });
                                }];
                            });
                        }
                        else {
                            NSLog(@"Registration Failed!");
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [[AppDelegate sharedAppDelegate] showLoader:NO];
                                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Error = %@",error] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                                [alertView show];
                            });
                        }

                    }];
                }
            }];
        }
        else {
            NSLog(@"Registration Failed!");
            // Show error
            dispatch_async(dispatch_get_main_queue(), ^{
                [[AppDelegate sharedAppDelegate] showLoader:NO];
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Error = %@",error] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alertView show];
            });
        }
        
    }];
    
    DGTAppearance *apperance = [[DGTAppearance alloc] init];
    apperance.accentColor = [OMAppearance appThemeColorWithAlpha:1];
    authenticateButton.digitsAppearance = apperance;
    CGPoint btnPos = CGPointMake(self.view.center.x, self.view.center.y);
    authenticateButton.center = btnPos;
    [authenticateButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    self.phoneNumberButton = authenticateButton;
    [self.view addSubview:authenticateButton];
    self.phoneNumberButton.enabled = NO;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.nameTextField)
    {
        if (self.phoneNumberButton.enabled) {
            
        } else {
            [textField resignFirstResponder];
        }
    }
    return YES;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    
    BOOL shouldChange = (newLength > 20) ? NO : YES;
    
    if (shouldChange) {
        [self enableNextButtonWithTextLength:newLength];
    }
    
    return shouldChange;
}


- (void)enableNextButtonWithTextLength:(NSInteger)textLength
{
    if (textLength == 0) {
        self.phoneNumberButton.enabled = NO;
    } else {
        self.phoneNumberButton.enabled = YES;
    }
}

-(void)tapAction:(UITapGestureRecognizer *)gestureRecognizer
{
    if([self.nameTextField isFirstResponder]) {
        [self.nameTextField resignFirstResponder];
    }
}
@end
