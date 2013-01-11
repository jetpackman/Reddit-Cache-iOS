//
//  SignUpViewController.h
//  onething
//
//  Created by Dane Carr on 12-04-17.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignUpViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UITextViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIButton *signUpButton;
@property (nonatomic, assign) CGSize keyboardSize;
@property (nonatomic, strong) NSMutableArray *tableCells;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (nonatomic, strong) User *user;


- (void)signup:(id)sender;
- (void)keyboardDidShow:(NSNotification*)notification;
- (void)keyboardDidHide:(NSNotification*)notification;
- (IBAction)cancelSignup:(id)sender;

@end
