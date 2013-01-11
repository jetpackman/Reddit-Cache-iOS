//
//  SignUpViewController.m
//  onething
//
//  Created by Dane Carr on 12-04-17.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import "SignUpViewController.h"
#import "LoginCell.h"
#import "FeedbackCell.h"
#import "MBProgressHUD.h"
#import "UIColor+Onething.h"
#import "TWGGroupedTableViewCellBackground.h"
#import "OnethingClientAPI.h"
#import "OnethingConstants.h"
#import "TWGDrawerViewController.h"


@implementation SignUpViewController

@synthesize cancelButton = _cancelButton;
@synthesize tableView = _tableView;
@synthesize signUpButton = _signUpButton;
@synthesize keyboardSize = _keyboardSize;
@synthesize tableCells = _tableCells;
@synthesize user = _user;

- (void)viewDidLoad
{
    [super viewDidLoad];
    

    self.tableView.backgroundColor = [UIColor tableBackgroundColour];
    
    self.signUpButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    UIImage *buttonBackground = [[UIImage imageNamed:@"button_sign_in.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(22, 12, 22, 12)];
    UIImage *buttonBackgroundHighlighted = [[UIImage imageNamed:@"button_sign_in_tap.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(22, 12, 22, 12)];
    
    [self.signUpButton setBackgroundImage:buttonBackground forState:UIControlStateNormal];
    [self.signUpButton setBackgroundImage:buttonBackgroundHighlighted forState:UIControlStateHighlighted];
    
    [self.signUpButton setTitle:@"Sign up!" forState:UIControlStateNormal];
    [self.signUpButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.signUpButton addTarget:self action:@selector(signup:) forControlEvents:UIControlEventTouchUpInside];
    [self.signUpButton setIsAccessibilityElement:YES];
    [self.signUpButton setAccessibilityLabel:@"Sign up"];
    // Create table cells
    self.tableCells = [NSMutableArray arrayWithCapacity:3];
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:4];
    
    for (int i = 0; i < 4; i++) {
        LoginCell *cell = (LoginCell*)[[UIViewController alloc] initWithNibName:@"LoginCell" bundle:nil].view;
        
        [cell.textField setReturnKeyType:UIReturnKeyNext];
        [cell.textField setDelegate:self];
        [cell.label setTextColor:[UIColor tableTextColour]];
        
        switch (i) {
            case 0:
                cell.label.text = @"Name";
                [cell.textField setKeyboardType:UIKeyboardTypeDefault];
                [cell.textField setIsAccessibilityElement:YES];
                [cell.textField setAccessibilityLabel:@"Name"];
                break;
            case 1:
                cell.label.text = @"Email";
                [cell.textField setKeyboardType:UIKeyboardTypeEmailAddress];
                [cell.textField setIsAccessibilityElement:YES];
                [cell.textField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
                [cell.textField setAutocorrectionType:UITextAutocorrectionTypeNo];
                [cell.textField setAccessibilityLabel:@"Email"];
                break;
            case 2:
                cell.label.text = @"Password";
                [cell.textField setKeyboardType:UIKeyboardTypeDefault];
                [cell.textField setClearsOnBeginEditing:YES];
                [cell.textField setSecureTextEntry:YES];
                [cell.textField setIsAccessibilityElement:YES];
                [cell.textField setAccessibilityLabel:@"Password"];
                break;
            case 3:
                cell.label.text = @"Password again";
                [cell.textField setKeyboardType:UIKeyboardTypeDefault];
                [cell.textField setClearsOnBeginEditing:YES];
                [cell.textField setSecureTextEntry:YES];
                [cell.textField setIsAccessibilityElement:YES];
                [cell.textField setAccessibilityLabel:@"Password again"];
                break;
            default:
                cell.label.text = @"cell";
                break;
        }
        
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
        
        [array addObject:cell];
    }
    
    [self.tableCells addObject:array];
    
    array = [NSMutableArray arrayWithCapacity:1];
    
    // Create "How did you hear about 1THING?" cell
    FeedbackCell *cell = (FeedbackCell*)[[UIViewController alloc] initWithNibName:@"FeedbackCell" bundle:nil].view;
    
    [cell.label setTextColor:[UIColor tableTextColour]];
    cell.textView.delegate = self;
    [cell.textView setReturnKeyType:UIReturnKeyDone];
    
    [array addObject:cell];
    [self.tableCells addObject:array];
    
    array = [NSMutableArray arrayWithCapacity:1];
    
    // Create Sign Up button cell
    UITableViewCell *buttonCell = [[UITableViewCell alloc] init];
    buttonCell.backgroundView = [TWGGroupedTableViewCellBackground backgroundWithBorderColor:[UIColor clearColor] fillColor:[UIColor clearColor] position:TWGGroupedTableViewCellPositionSingle];
    
    self.signUpButton.frame = CGRectMake(10, 0, 280, 45);
    [buttonCell.contentView addSubview:self.signUpButton];
    
    
    [array addObject:buttonCell];
    [self.tableCells addObject:array];
}

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
    
    // Register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated 
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - TableView

// Static cells prevent textField data from being lost when scrolled offscreen and recycled by tableView
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (UITableViewCell*)[[self.tableCells objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 || indexPath.section == 2) {
        return 44.0f;
    }
    else {
        return 100.0f;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 4;
    }
    else {
        return 1;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}
     
- (void)keyboardDidShow:(NSNotification *)notification
{
    self.keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    // Prevent tableView content from being covered by keyboard
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0, 0, self.keyboardSize.height, 0);
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
}

- (void)keyboardDidHide:(NSNotification *)notification
{
    // Allow tableView content to fill screen again
    self.tableView.contentInset = UIEdgeInsetsZero;
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsZero;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{    

    NSIndexPath *indexPath = [self.tableView indexPathForCell:(LoginCell*)textField.superview.superview];
    if (indexPath.row == 3) {
        // Change focus to feedback cell
        [[(FeedbackCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]] textView] becomeFirstResponder];
    }
    else {
        // Change focus to next cell
        [[(LoginCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:(indexPath.row + 1) inSection:indexPath.section]] textField] becomeFirstResponder];
    }
    
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    // Mimic textField behaviour by performing done action when enter key is pressed
    if ([text isEqualToString:@"\n"]) {
        [self signup:textView];
        return NO;
    }
    return YES;
}

- (void)signup:(id)sender
{
    UITextField *nameField =  [((LoginCell*)[[self.tableCells objectAtIndex:0] objectAtIndex:0]) textField];
    UITextField *emailField =  [((LoginCell*)[[self.tableCells objectAtIndex:0] objectAtIndex:1]) textField];
    UITextField *passwordField =  [((LoginCell*)[[self.tableCells objectAtIndex:0] objectAtIndex:2]) textField];
    UITextField *passwordAgainField =  [((LoginCell*)[[self.tableCells objectAtIndex:0] objectAtIndex:3]) textField];
    UITextView *commentView = [((FeedbackCell*)[[self.tableCells objectAtIndex:1] objectAtIndex:0]) textView];
    NSString *name =  nameField.text;
    NSString *email =  emailField.text;
    NSString *password =  passwordField.text;
    NSString *passwordAgain =  passwordAgainField.text;
    NSString *comment = commentView.text;

    
    if (name.length > 0 && email.length > 0 && password.length > 0) {
        
        [nameField resignFirstResponder];
        [emailField resignFirstResponder];
        [passwordField resignFirstResponder];
        [passwordAgainField resignFirstResponder];
        [commentView resignFirstResponder];

        
        
        // Validate password
        if (![password isEqualToString:passwordAgain]) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.dimBackground = YES;
            hud.labelText = @"Passwords do not match!";
            hud.margin = 10.0f;
            hud.removeFromSuperViewOnHide = YES;
            [hud hide:YES afterDelay:2];
            return;
        }
        
        if ([password isEqualToString:@""]) {
            // If the password field is empty
            password = nil;
        }
        // Show login activity indicator
        
        MBProgressHUD *signupStatusHud = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:signupStatusHud];
        signupStatusHud.removeFromSuperViewOnHide = YES;
        signupStatusHud.mode = MBProgressHUDModeIndeterminate;
        signupStatusHud.labelText = @"Creating Account";
        [signupStatusHud show:YES];
        
        
        [[OnethingClientAPI sharedClient] signupUserWithName:name
                                                    username:email                                                 
                                                    password:password
                                                    feedback:comment
                                                     startup:nil
                                                     success:^(id responseUser) {
                                                         // Network request was successful
                                                         [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                                             // Hide login activity indicator
                                                             //[signupStatusHud hide:YES];
                                                             
                                                             User *user = (User*)responseUser;
                                                             
                                                             if (user) {
                                                                 // Signup was successful
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
                                                                 
                                                                 // Pop the view controller back to the landing page after logging in such that when we signout we are back at the landing page and not the signup screen.
                                                                 double delayInSeconds = 0.3;
                                                                 dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                                                                 dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                                                     [self.navigationController popViewControllerAnimated:NO];
                                                                 });               
                                                             }
                                                             else {
                                                                 // Signup failed
                                                                 MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                                                                 hud.mode = MBProgressHUDModeText;
                                                                 hud.dimBackground = YES;
                                                                 hud.labelText = @"Account Creation Failed";
                                                                 hud.margin = 10.0f;
                                                                 hud.removeFromSuperViewOnHide = YES;
                                                                 
                                                                 [hud hide:YES afterDelay:2];
                                                             }
                                                         }];
                                                     } failure:^(NSHTTPURLResponse *response, NSError *error) {
                                                         // Network request failed
                                                         [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                                             NSLog(@"[ERROR] Failed to login: {http response: %@, error: %@}", response.debugDescription, [error userInfo]);
                                                             [signupStatusHud hide:YES];

                                                             MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                                                             hud.mode = MBProgressHUDModeText;
                                                             hud.dimBackground = YES;
                                                             hud.margin = 10.0f;
                                                             hud.labelText = @"This email is already registered";
                                                             hud.removeFromSuperViewOnHide = YES;
                                                             [hud hide:YES afterDelay:2];

                                                         }];
                                                     } completion:nil];
    }
}


- (IBAction)cancelSignup:(id)sender
{
    // Return to Landing Page
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)viewDidUnload 
{
    [self setCancelButton:nil];
    [super viewDidUnload];
}
@end
