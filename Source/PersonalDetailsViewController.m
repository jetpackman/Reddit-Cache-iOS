//
//  PersonalDetailsViewController.m
//  onething
//
//  Created by Dane Carr on 12-03-01.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import "PersonalDetailsViewController.h"
#import "LoginCell.h"
#import "OnethingClientAPI.h"

@implementation PersonalDetailsViewController

@synthesize tableView = _tableView;
@synthesize saveButton = _saveButton;
@synthesize user = _user;
@synthesize updateOperation = _updateOperation;
@synthesize emailSwitch = _emailSwitch;

- (id)initWithUser:(User*)user
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.user = user;
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"Personal Details"];
    // Do any additional setup after loading the view from its nib.
    self.emailSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];

    self.saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(saveChanges:)];
    [self.navigationItem setRightBarButtonItem:self.saveButton];
    
    [self.tableView setBackgroundColor:[UIColor tableBackgroundColour]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidAppear:(BOOL)animated 
{
    [super viewDidAppear:animated];
    
//    [[(LoginCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] textField] becomeFirstResponder];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)saveChanges:(id)sender
{
    // Only one update operation at a time
    if (self.updateOperation) {
        return;
    }
    
    
    // Get data from table textFields
    UITextField *nameField = ((LoginCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]).textField;
    UITextField *emailField = ((LoginCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]]).textField;
    UITextField *passwordField = ((LoginCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]]).textField;
    UITextField *passwordAgainField = ((LoginCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]]).textField;
    NSString* name = nameField.text;
    NSString* email = emailField.text;
    NSString* password = passwordField.text;
    NSString* passwordAgain = passwordAgainField.text;
    
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
    
    // Hide Keyboard
    [nameField resignFirstResponder];
    [emailField resignFirstResponder];
    [passwordField resignFirstResponder];
    [passwordAgainField resignFirstResponder];
    
    MBProgressHUD *updatingStatusHud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:updatingStatusHud];
    updatingStatusHud.removeFromSuperViewOnHide = YES;
    updatingStatusHud.dimBackground = YES;
    updatingStatusHud.mode = MBProgressHUDModeIndeterminate;
    updatingStatusHud.labelText = @"Saving...";
    [updatingStatusHud show:YES];

    
    [[OnethingClientAPI sharedClient] updateUserWithName:name 
                                                password:password
                                                   email:email
                                                  apiKey:self.user.apiKey
                                      receivesNewsletter:self.emailSwitch.on ? @"1" : @"0"
                                                 startup:^(NSOperation *operation) {
                                                     // Startup
                                                     self.updateOperation = operation;                                                     
                                                 }
                                                 success:^(id responseUser) {
                                                     // Success
                                                     updatingStatusHud.labelText = @"Saved!";
                                                     User* returnedUser = (User*) responseUser;
                                                     
                                                     self.user.name = returnedUser.name;
                                                     self.user.email = returnedUser.email;
                                                     self.user.apiKey = returnedUser.apiKey;
                                                     self.user.userId = returnedUser.userId;
                                                     self.user.receivesNewsletter = returnedUser.receivesNewsletter;
                                                     
                                                     [updatingStatusHud hide:YES afterDelay:0.3];

                                                     [self performAfterDelay:0.5 onQueue:[NSOperationQueue mainQueue] block: ^(void){
                                                         [[self navigationController] popViewControllerAnimated:YES];
                                                     }];
                                                     
                                                 } 
                                                 failure:^(NSHTTPURLResponse *response, NSError *error) {
                                                     // Failure
                                                     [updatingStatusHud hide:YES];
                                                     MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                                                     hud.mode = MBProgressHUDModeText;
                                                     hud.dimBackground = YES;
                                                     hud.labelText = @"Failed to update your details";
                                                     hud.margin = 10.0f;
                                                     hud.removeFromSuperViewOnHide = YES;
                                                     
                                                     [hud hide:YES afterDelay:1.0];
                                                     [self performAfterDelay:1.25 onQueue:[NSOperationQueue mainQueue] block: ^(void){
                                                         [nameField becomeFirstResponder];
                                                     }];
                                                 } 
                                              completion:^{
                                                  // Completion
                                                  self.updateOperation = nil;
                                              }
     ];    
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    LoginCell *cell = (LoginCell*)[[UIViewController alloc] initWithNibName:@"LoginCell" bundle:nil].view;

    [cell.textField setReturnKeyType:UIReturnKeyNext];
    [cell.textField setDelegate:self];
    
    switch (indexPath.row) {
        case 0:
            cell.label.text = @"Name";
            cell.textField.text = self.user.name;
            [cell.textField setKeyboardType:UIKeyboardTypeDefault];
            [cell.textField setAccessibilityLabel:@"Name Field"];

            break;
        case 1:
            cell.label.text = @"Email";
            cell.textField.text = self.user.email;
            [cell.textField setKeyboardType:UIKeyboardTypeEmailAddress];
            [cell.textField setAccessibilityLabel:@"Email Field"];
            [cell.textField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
            [cell.textField setAutocorrectionType:UITextAutocorrectionTypeNo];

            break;
        case 2:
            cell.label.text = @"Password";
            [cell.textField setKeyboardType:UIKeyboardTypeDefault];
            [cell.textField setClearsOnBeginEditing:YES];
            [cell.textField setSecureTextEntry:YES];
            [cell.textField setAccessibilityLabel:@"Password Field"];

            break;
        case 3:
            cell.label.text = @"Password again";
            [cell.textField setKeyboardType:UIKeyboardTypeDefault];
            [cell.textField setClearsOnBeginEditing:YES];
            [cell.textField setSecureTextEntry:YES];
            [cell.textField setReturnKeyType:UIReturnKeyDone];
            [cell.textField setAccessibilityLabel:@"Password again Field"];
            break;
            
        case 4:
            cell.label.text = @"Daily emails";
            cell.textField.hidden = YES;
            cell.accessoryView = self.emailSwitch;
            self.emailSwitch.on = [self.user.receivesNewsletter intValue];
            break;
        default:
            cell.label.text = @"cell";
            break;
    }
    
    CGRect labelFrame = cell.label.frame;
    CGRect textFieldFrame = cell.textField.frame;
    
    labelFrame.size.width = [cell.label.text sizeWithFont:cell.label.font forWidth:300 lineBreakMode:NSLineBreakByTruncatingTail].width;
    
    // cell width - label width - cell left margin - middle margin - cell right margin
    textFieldFrame.size.width = 300 - labelFrame.size.width - labelFrame.origin.x - 25;
    // margin width + label width + margin width
    textFieldFrame.origin.x = labelFrame.origin.x + labelFrame.size.width + 10;
    
    cell.label.frame = labelFrame;
    cell.textField.frame = textFieldFrame;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return 5;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField 
{
     NSIndexPath *indexPath = [self.tableView indexPathForCell:(LoginCell*)textField.superview.superview];
    
    if (indexPath.row == 3) {
        [textField resignFirstResponder];
    }
    else {
        [[(LoginCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:(indexPath.row + 1) inSection:0]] textField] becomeFirstResponder];
    }
    
    return YES;
}

@end
