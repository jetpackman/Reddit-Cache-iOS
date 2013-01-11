//
//  LandingPageViewController.m
//  onething
//
//  Created by Dane Carr on 12-02-14.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import "LandingPageViewController.h"
#import "MyJournalViewController.h"
#import "TWGMenuController.h"
#import "TWGDrawerViewController.h"
#import "LoginViewController.h"
#import "SignUpViewController.h"

@implementation LandingPageViewController

@synthesize getStartedNowButton = _getStartedNowButton;
@synthesize iHaveAnAccountButton = _iHaveAnAccountButton;
@synthesize activityIndicator = _activityIndicator;
@synthesize loginOperation = _loginOperation;

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.activityIndicator.hidden = YES;
    
    self.navigationController.navigationBarHidden = YES;
    
    self.getStartedNowButton.hidden = YES;
    self.iHaveAnAccountButton.hidden = YES;
    
    UIImage *newUserButtonBackground = [[UIImage imageNamed:@"button_new_user.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(22, 13, 22, 13)];
    UIImage *newUserButtonBackgroundHighlighted = [[UIImage imageNamed:@"button_new_user_tap.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(22, 13, 22, 13)];
    
    [self.getStartedNowButton setBackgroundImage:newUserButtonBackground forState:UIControlStateNormal];
    [self.getStartedNowButton setBackgroundImage:newUserButtonBackgroundHighlighted forState:UIControlStateHighlighted];
    
    UIImage *returningUserButtonBackground = [[UIImage imageNamed:@"button_returning_user.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(22, 13, 22, 13)];
    UIImage *returningUserButtonBackgroundHighlighted = [[UIImage imageNamed:@"button_returning_user_tap.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(22, 13, 22, 13)];
    
    [self.iHaveAnAccountButton setBackgroundImage:returningUserButtonBackground forState:UIControlStateNormal];
    [self.iHaveAnAccountButton setBackgroundImage:returningUserButtonBackgroundHighlighted forState:UIControlStateHighlighted];
    
    [self.getStartedNowButton.titleLabel setFont:[UIFont fontWithName:@"QuattrocentoSans-Bold" size:18]];
    [self.iHaveAnAccountButton.titleLabel setFont:[UIFont fontWithName:@"QuattrocentoSans-Bold" size:18]];
    

}

- (void)viewDidAppear:(BOOL)animated 
{
    [super viewDidAppear:animated];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults boolForKey:UserDefaultsLoggedIn]) {
        // One request at a time
        if (self.loginOperation) {
            return;
        }
        
        [self showActivityIndicator];
        
        // Validate stored API key
        [[OnethingClientAPI sharedClient] renewLoginWithKey:[defaults objectForKey:UserDefaultsApiKey] startup:^(NSOperation *operation){
            self.loginOperation = operation;
        } success:^(id responseUser) {
            // Network request was successful
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{                
                [self hideActivityIndicator];
                
                User *user = (User*)responseUser;
                
                if (user) {
                    // Login successful, updated stored values
                    [defaults setBool:YES forKey:UserDefaultsLoggedIn];
                    [defaults setObject:user.apiKey forKey:UserDefaultsApiKey];
                    [defaults synchronize];
                    
                    // Create menu controller and drawer
                    [self showMenuControllerWithUser:user];
                }
                else {
                    // Login unsuccessful
                    [defaults setBool:NO forKey:UserDefaultsLoggedIn];
                    [defaults synchronize];
                    
                    [self showFailureHUD];
                    
                    // Show login buttons
                    if (self.getStartedNowButton.hidden || self.iHaveAnAccountButton.hidden) {
                        [self fadeInButtons];
                    }
                }
            }];
        } failure:^(NSHTTPURLResponse *response, NSError *error) {
            // Network request failed
            NSLog(@"[ERROR] Failed to login: {http response: %@, error: %@}", response.debugDescription, [error userInfo]);
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{                
                [self hideActivityIndicator];
                
                [self showFailureHUD];
                
                [self fadeInButtons];
            }];
        } completion:^{
            self.loginOperation = nil;
        }];
    }
    else {
        // User is not logged in alread, show login buttons
        if (self.getStartedNowButton.hidden || self.iHaveAnAccountButton.hidden) {
            [self fadeInButtons];
        }
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Login view

- (void)showActivityIndicator
{
    // Disable buttons during network request
    [self.activityIndicator startAnimating];
    self.activityIndicator.hidden = NO;
    self.getStartedNowButton.enabled = NO;
    self.iHaveAnAccountButton.enabled = NO;
}

- (void)hideActivityIndicator 
{
    // Enable buttons after network request
    self.activityIndicator.hidden = YES;
    [self.activityIndicator stopAnimating];
    self.getStartedNowButton.enabled = YES;
    self.iHaveAnAccountButton.enabled = YES;
}

- (void)fadeInButtons
{
    self.getStartedNowButton.alpha = 0;
    self.iHaveAnAccountButton.alpha = 0;
    
    self.getStartedNowButton.hidden = NO;
    self.iHaveAnAccountButton.hidden = NO;
    
    [UIView animateWithDuration:0.5 animations:^{
        self.getStartedNowButton.alpha = 1;
        self.iHaveAnAccountButton.alpha = 1;
    } completion:nil];
}

- (void)showFailureHUD 
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.dimBackground = YES;
    hud.labelText = @"Login Failed";
    hud.margin = 10.0f;
    hud.removeFromSuperViewOnHide = YES;
    hud.yOffset = 75;
    
    [hud hide:YES afterDelay:2];
}

#pragma mark - Actions

- (void) showMenuControllerWithUser:(User*)user
{
    TWGDrawerViewController *leftDrawer = [[TWGDrawerViewController alloc] initWithNibName:nil bundle:nil user:user];
    TWGMenuController *menuController = [[TWGMenuController alloc] initWithLeftDrawer:leftDrawer RightDrawer:nil andRootViewController:[[[leftDrawer.tableData objectAtIndex:0] objectAtIndex:0] objectForKey:@"object"]];
    
    [menuController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    
    [self presentViewController:menuController animated:YES completion:nil];
    
}

- (IBAction)loginButtonPressed:(id)sender
{
    // Show login screen
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    // If the user was logged in, but hits a network error such that the landing page doesnt auto-login, the login button should allow auto-login
    if ([defaults boolForKey:UserDefaultsLoggedIn]) {
        // One request at a time
        if (self.loginOperation) {
            return;
        }
        
        [self showActivityIndicator];
        
        // Validate stored API key
        [[OnethingClientAPI sharedClient] renewLoginWithKey:[defaults objectForKey:UserDefaultsApiKey] startup:^(NSOperation *operation){
            self.loginOperation = operation;
        } success:^(id responseUser) {
            // Network request was successful
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{                
                [self hideActivityIndicator];
                
                User *user = (User*)responseUser;
                
                if (user) {
                    // Login successful, updated stored values
                    [defaults setBool:YES forKey:UserDefaultsLoggedIn];
                    [defaults setObject:user.apiKey forKey:UserDefaultsApiKey];
                    [defaults synchronize];
                    
                    // Create menu controller and drawer
                    [self showMenuControllerWithUser:user];
                }
                else {
                    // Login unsuccessful
                    [defaults setBool:NO forKey:UserDefaultsLoggedIn];
                    [defaults synchronize];
                    
                    [self showFailureHUD];
                }
            }];
        } failure:^(NSHTTPURLResponse *response, NSError *error) {                
            NSLog(@"[ERROR] Failed to login: {http response: %@, error: %@}", response.debugDescription, [error userInfo]);
            if ([response respondsToSelector:@selector(statusCode)] && [((NSHTTPURLResponse*)response) statusCode] == 401) {
                // Network request failed due to bad API key / bad access
                [defaults setBool:NO forKey:UserDefaultsLoggedIn];
                [defaults synchronize];
                [self hideActivityIndicator];

                LoginViewController *viewController = [[LoginViewController alloc] init];
                [self.navigationController pushViewController:viewController animated:YES];
            } else {
                // Network request failed for other reasons
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{                
                    [self hideActivityIndicator];
                    [self showFailureHUD];
                 }];
            }
        } completion:^{
            self.loginOperation = nil;
        }];
    }
    else {
        [defaults setBool:NO forKey:UserDefaultsLoggedIn];
        [defaults synchronize];
        LoginViewController *viewController = [[LoginViewController alloc] init];
        [self.navigationController pushViewController:viewController animated:YES];
    }

    

}

- (IBAction)signupButtonPressed:(id)sender
{
    // Show signup screen
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:NO forKey:UserDefaultsLoggedIn];
    [defaults synchronize];
    
    SignUpViewController *viewController = [[SignUpViewController alloc] initWithNibName:@"SignUpViewController" bundle:nil];
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
