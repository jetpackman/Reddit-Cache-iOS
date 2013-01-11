//
//  CreateReminderViewController.h
//  onething
//
//  Created by Dane Carr on 12-03-02.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reminder.h"

typedef void(^CreateReminderCallbackBlock)(Reminder *reminder);
typedef void(^DeleteReminderCallbackBlock)(NSString* reminderId);

@interface CreateReminderViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, copy)CreateReminderCallbackBlock createReminderCallbackBlock;
@property (nonatomic, copy)DeleteReminderCallbackBlock deleteReminderCallbackBlock;
@property (nonatomic, weak) IBOutlet UIDatePicker *datePicker;
@property (nonatomic, strong) UIBarButtonItem *cancelButton;
@property (nonatomic, strong) UIBarButtonItem *saveButton;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, assign) BOOL editingReminder;
@property (nonatomic, strong) Reminder *reminder;
@property (nonatomic, strong) UISwitch *soundSwitch;
@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) UIImage *chevronImage;

- (void)cancelReminderCreation:(id)sender;
- (void)createReminder:(id)sender;
- (void)deleteReminder:(id)sender;
- (void)soundSwitchToggled:(id)sender;

@end
