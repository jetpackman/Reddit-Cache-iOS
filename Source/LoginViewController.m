//
//  LoginViewController.m
//  onething
//
//  Created by Dane Carr on 12-02-10.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import "LoginViewController.h"
#import "TWGDrawerViewController.h"
#import "TWGMenuController.h"
#import "LoginCell.h"
#import "SignUpViewController.h"
#import "ResetPasswordViewController.h"

@implementation LoginViewController

@synthesize cancelButton = _cancelButton;
@synthesize tableView = _tableView;
@synthesize signInButton = _signInButton;
@synthesize forgotPasswordButton = _forgotPasswordButton;
@synthesize inputArray = _inputArray;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView setBackgroundColor:[UIColor tableBackgroundColour]];
    
    self.inputArray = [NSMutableArray array];
    
    [self.inputArray addObject:@""];
    [self.inputArray addObject:@""];
    
    self.signInButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    UIImage *buttonBackground = [[UIImage imageNamed:@"button_sign_in.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(22, 12, 22, 12)];
    UIImage *buttonBackgroundHighlighted = [[UIImage imageNamed:@"button_sign_in_tap.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(22, 12, 22, 12)];
    
    [self.signInButton setBackgroundImage:buttonBackground forState:UIControlStateNormal];
    [self.signInButton setBackgroundImage:buttonBackgroundHighlighted forState:UIControlStateHighlighted];
    
    [self.signInButton setTitle:@"Sign in" forState:UIControlStateNormal];
    [self.signInButton setTintColor:[UIColor whiteColor]];
    [self.signInButton addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
    [self.signInButton setAccessibilityLabel:@"Sign In"];
    
    self.forgotPasswordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.forgotPasswordButton setBackgroundColor:[UIColor clearColor]];
    [self.forgotPasswordButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [self.forgotPasswordButton setTitle:@"I forgot my password »" forState:UIControlStateNormal];
    [self.forgotPasswordButton setTitleColor:[UIColor tableTextColour] forState:UIControlStateNormal];
    [self.forgotPasswordButton addTarget:self action:@selector(forgotPassword:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Set email field as first responder
    [[(LoginCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] textField] becomeFirstResponder];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - TableView

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        LoginCell *cell = (LoginCell*) [[UIViewController alloc] initWithNibName:@"LoginCell" bundle:nil].view;
        [cell.label setTextColor:[UIColor tableTextColour]];
        if (indexPath.row == 0) {
            // Email field
            cell.label.text = @"Email";
            [cell.textField setReturnKeyType:UIReturnKeyNext];
            [cell.textField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
            [cell.textField setAutocorrectionType:UITextAutocorrectionTypeNo];
            [cell.textField setClearsOnBeginEditing:NO];
            [cell.textField setKeyboardType:UIKeyboardTypeEmailAddress];
            [cell.textField setAccessibilityLabel:@"Email"];
            [cell.textField setTag:0];
            
        }
        else {
            // Password field
            cell.label.text = @"Password";
            [cell.textField setSecureTextEntry:YES];
            [cell.textField setReturnKeyType:UIReturnKeyDone];
            [cell.textField setClearsOnBeginEditing:YES];
            [cell.textField setKeyboardType:UIKeyboardTypeDefault];
            [cell.textField setAccessibilityLabel:@"Password"];
            [cell.textField setTag:1];
            
        }
        
        cell.textField.delegate = self;
        
        // Resize label to fit text and textField to fill remaining cell space
        CGRect labelFrame = cell.label.frame;
        CGRect textFieldFrame = cell.textField.frame;
        
        labelFrame.size.width = [cell.label.text sizeWithFont:cell.label.font forWidth:300 lineBreakMode:NSLineBreakByTruncatingTail].width;
        
        // cell width - label width - cell left margin - middle margin - cell right margin
        textFieldFrame.size.width = 300 - labelFrame.size.width - labelFrame.origin.x - 25;
        // margin width + label width + margin width
        textFieldFrame.origin.x = labelFrame.origin.x + labelFrame.size.width + 10;
        
        cell.label.frame = labelFrame;
        cell.textField.frame = textFieldFrame;
        NSLog(@"%@", [self.inputArray objectAtIndex:indexPath.row]);
        cell.textField.text = [self.inputArray objectAtIndex:indexPath.row];
        
        
        return cell;
    } else if (indexPath.section == 1) {
        // Sign in button
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        cell.backgroundView = [TWGGroupedTableViewCellBackground backgroundWithBorderColor:[UIColor clearColor] fillColor:[UIColor clearColor] position:TWGGroupedTableViewCellPositionSingle];
        
        self.signInButton.frame = CGRectMake(10, 10, 280, 45);
        [cell.contentView addSubview:self.signInButton];
        return cell;
    } else {
        // Forgot password
        // Sign in button
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        cell.backgroundView = [TWGGroupedTableViewCellBackground backgroundWithBorderColor:[UIColor clearColor] fillColor:[UIColor clearColor] position:TWGGroupedTableViewCellPositionSingle];
        
        self.forgotPasswordButton.frame = CGRectMake(10, 0, 280, 45);
        [cell.contentView addSubview:self.forgotPasswordButton];
        
        return cell;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == 3) {
        return 24.0f;
    }
    else {
        return 44.0f;
    }
}
-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0)
        return 6;
    return 1.0;
}


-(CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section
{
    return 5.0;
}

#pragma mark - Actions

- (void)login:(id)sender
{
    
    UITextField *emailField = [(LoginCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] textField];
    UITextField *passwordField = [(LoginCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] textField];
    
    if (emailField.text.length > 0 && passwordField.text.length > 0) {
        
        // Hide keyboard
        [passwordField resignFirstResponder];
        [emailField resignFirstResponder];
        
        // Show login activity indicator
        MBProgressHUD *loginStatusHud = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:loginStatusHud];
        loginStatusHud.removeFromSuperViewOnHide = YES;
        loginStatusHud.mode = MBProgressHUDModeIndeterminate;
        loginStatusHud.labelText = @"Logging In";
        [loginStatusHud show:YES];
        
        [[OnethingClientAPI sharedClient] loginWithUsername:emailField.text password:passwordField.text startup:nil success:^(id responseUser) {
            // Network request was successful
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                // Hide login activity indicator
                [loginStatusHud hide:YES];
                
                User *user = (User*)responseUser;
                
                if (user) {
                    // Login was successful
                    // Store API key
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setBool:YES forKey:UserDefaultsLoggedIn];
                    [defaults setObject:user.apiKey forKey:UserDefaultsApiKey];
                    [defaults synchronize];
                    
                    // Create menu controller and drawer
                    TWGDrawerViewController *leftDrawer = [[TWGDrawerViewController alloc] initWithNibName:nil bundle:nil user:user];
                    TWGMenuController *menuController = [[TWGMenuController alloc] initWithLeftDrawer:leftDrawer RightDrawer:nil andRootViewController:[[[leftDrawer.tableData objectAtIndex:0] objectAtIndex:0] objectForKey:@"object"]];
                    
                    [menuController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
                    
                    [self presentViewController:menuController animated:YES completion:nil];
                    
                    // Pop the view controller back to the landing page after logging in such that when we signout we are back at the landing page and not the login screen.
                    [self performAfterDelay:0.3
                                    onQueue:[NSOperationQueue mainQueue]
                                      block: ^(void){
                                          [self.navigationController popViewControllerAnimated:NO];
                                      }];
                } else {
                    // Login failed
                    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
                    hud.mode = MBProgressHUDModeText;
                    hud.dimBackground = YES;
                    hud.labelText = @"Login Failed";
                    hud.margin = 10.0f;
                    hud.removeFromSuperViewOnHide = YES;
                    
                    [hud hide:YES afterDelay:2];
                }
            }];
        } failure:^(NSHTTPURLResponse *response, NSError *error) {
            // Network request failed
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                NSLog(@"[ERROR] Failed to login: {http response: %@, error: %@}", response.debugDescription, [error userInfo]);
                
                [loginStatusHud hide:YES];
                
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
                hud.mode = MBProgressHUDModeText;
                hud.dimBackground = YES;
                hud.margin = 10.0f;
                hud.removeFromSuperViewOnHide = YES;
                
                if (response.statusCode == 401) {
                    // Received 401 UNAUTHORIZED response
                    hud.labelText = @"Invalid email or password";
                    // Make password field first responder
                    [[(LoginCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] textField] becomeFirstResponder];
                }
                else {
                    hud.labelText = @"Login Failed";
                }
                
                [hud hide:YES afterDelay:2];
            }];
        } completion:nil];
    }
}

- (void)forgotPassword:(id)sender
{
    //    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Forgot your password?" message:@"Enter your email address below" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Reset", nil ];
    //    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    //
    //    UITextField *alertTextField = [alert textFieldAtIndex:0];
    //    alertTextField.placeholder = @"Enter your email address";
    //
    //    [alert show];
    
    ResetPasswordViewController *vc = [[ResetPasswordViewController alloc] initWithNibName:@"ResetPasswordViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString* detailString = [alertView textFieldAtIndex:0].text;
    NSLog(@"String is: %@", detailString); //Put it on the debugger
    if ([detailString length] <= 0 || buttonIndex == 0){
        return; //If cancel or 0 length string the string doesn't matter
    }
    if (buttonIndex == 1) {
        NSLog(@"RESET!");
        alertView.message = @"Check your email to reset your password";
        
    }
}

- (IBAction)cancelLogin:(id)sender
{
    // Return to Landing Page
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    if (textField.returnKeyType == UIReturnKeyNext) {
        // Move to next field
        [[(LoginCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] textField] becomeFirstResponder];
    }
    else if (textField.returnKeyType == UIReturnKeyDone) {
        // Send login request
        [textField resignFirstResponder];
        [self login:textField];
    }
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField.tag == 0) {
        [self.inputArray replaceObjectAtIndex:0 withObject:textField.text];
    }
    else if (textField.tag == 1) {
        [self.inputArray replaceObjectAtIndex:1 withObject:textField.text];
    }
}

@end
