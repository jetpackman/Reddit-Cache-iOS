//
//  ResetPasswordViewController.h
//  onething
//
//  Created by Anthony Wong on 2012-08-22.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResetPasswordViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)cancelTouched:(id)sender;
@property (nonatomic, strong) UIButton *resetButton;
@end
