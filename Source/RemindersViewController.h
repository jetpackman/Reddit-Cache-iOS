//
//  RemindersViewController.h
//  onething
//
//  Created by Dane Carr on 12-03-01.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reminder.h"
#import "BaseViewController.h"

@interface RemindersViewController : BaseViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIBarButtonItem *createReminderButton;
@property (nonatomic, strong) NSMutableArray *reminders;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSCalendar *gregorianCalendar;
@property (nonatomic, strong) UIImage *chevronImage;

- (void)createReminder:(id)sender;

@end
