//
//  ResetPasswordViewController.m
//  onething
//
//  Created by Anthony Wong on 2012-08-22.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import "ResetPasswordViewController.h"
#import "LoginCell.h"

@interface ResetPasswordViewController ()

@end

@implementation ResetPasswordViewController
@synthesize tableView = _tableView;
@synthesize resetButton = _resetButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView setBackgroundColor:[UIColor tableBackgroundColour]];
    
    self.resetButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    UIImage *buttonBackground = [[UIImage imageNamed:@"button_sign_in.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(22, 12, 22, 12)];
    UIImage *buttonBackgroundHighlighted = [[UIImage imageNamed:@"button_sign_in_tap.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(22, 12, 22, 12)];
    
    [self.resetButton setBackgroundImage:buttonBackground forState:UIControlStateNormal];
    [self.resetButton setBackgroundImage:buttonBackgroundHighlighted forState:UIControlStateHighlighted];
    
    [self.resetButton setTitle:@"Reset Password" forState:UIControlStateNormal];
    [self.resetButton setTintColor:[UIColor whiteColor]];
    [self.resetButton addTarget:self action:@selector(resetPassword:) forControlEvents:UIControlEventTouchUpInside];
    [self.resetButton setAccessibilityLabel:@"Reset Password"];
    
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
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
            [cell.textField setReturnKeyType:UIReturnKeyDone];
            [cell.textField setClearsOnBeginEditing:NO];
            [cell.textField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
            [cell.textField setAutocorrectionType:UITextAutocorrectionTypeNo];
            [cell.textField setKeyboardType:UIKeyboardTypeEmailAddress];
            [cell.textField setAccessibilityLabel:@"Email"];
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
        
        return cell;
    } else {
        // Sign in button
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        cell.backgroundView = [TWGGroupedTableViewCellBackground backgroundWithBorderColor:[UIColor clearColor] fillColor:[UIColor clearColor] position:TWGGroupedTableViewCellPositionSingle];
        
        self.resetButton.frame = CGRectMake(10, 0, 280, 45);
        [cell.contentView addSubview:self.resetButton];
        return cell;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.returnKeyType == UIReturnKeyDone) {
        // Send login request
        [textField resignFirstResponder];
        [self resetPassword:textField];
    }
    
    return YES;
}

- (void)resetPassword:(id)sender
{
    UITextField *emailField = [(LoginCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] textField];
    
    [[OnethingClientAPI sharedClient]
     resetPasswordWithEmail:emailField.text
     startup:nil
     success:^(id responseObject){
        
         UIAlertView* av = [[UIAlertView alloc] initWithTitle:@"Password Reset" message:@"Please see your email to reset your password." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
         
         [av show];
         
         [self.navigationController popViewControllerAnimated:YES];
         
     }
     failure:^(NSHTTPURLResponse *response, NSError *error) {
         UIAlertView* av = [[UIAlertView alloc] initWithTitle:@"Password Reset" message:@"Couldn't find a user with that email." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
         
         [av show];
     }
     completion:nil];
}


- (IBAction)cancelTouched:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];

}
@end
