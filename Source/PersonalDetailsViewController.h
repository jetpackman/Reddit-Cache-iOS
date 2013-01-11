//
//  PersonalDetailsViewController.h
//  onething
//
//  Created by Dane Carr on 12-03-01.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
@interface PersonalDetailsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIBarButtonItem *saveButton;
@property (nonatomic, strong) User* user;
@property (nonatomic, strong) NSOperation* updateOperation;
@property (nonatomic, strong) UISwitch* emailSwitch;

- (void)saveChanges:(id)sender;
- (id)initWithUser:(User*)user;
@end
