//
//  LandingPageViewController.h
//  onething
//
//  Created by Dane Carr on 12-02-14.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "MyJournalViewController.h"

@interface LandingPageViewController : UIViewController <UIAlertViewDelegate>

@property (nonatomic, weak) IBOutlet UIButton* getStartedNowButton;
@property (nonatomic, weak) IBOutlet UIButton* iHaveAnAccountButton;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) NSOperation *loginOperation;

- (IBAction)loginButtonPressed:(id)sender;
- (IBAction)signupButtonPressed:(id)sender;
- (void)fadeInButtons;
- (void)showActivityIndicator;
- (void)hideActivityIndicator;
- (void)showMenuControllerWithUser:(User*)user;
- (void)showFailureHUD;
@end
