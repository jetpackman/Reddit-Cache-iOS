//
//  SettingsViewController.h
//  onething
//
//  Created by Dane Carr on 12-03-01.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
@interface SettingsViewController : BaseViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) User *user;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIImage *chevronImage;

- (void)swipe:(UISwipeGestureRecognizer*)recognizer direction:(UISwipeGestureRecognizerDirection)direction;
@end
