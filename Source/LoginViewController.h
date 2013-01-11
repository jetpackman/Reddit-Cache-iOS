//
//  LoginViewController.h
//  onething
//
//  Created by Dane Carr on 12-02-10.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "MyJournalViewController.h"

@interface LoginViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UIBarButtonItem *cancelButton;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIButton *signInButton;
@property (nonatomic, strong) UIButton *forgotPasswordButton;
@property (nonatomic, strong) NSMutableArray *inputArray;

- (void)login:(id)sender;
- (IBAction)cancelLogin:(id)sender;

@end
