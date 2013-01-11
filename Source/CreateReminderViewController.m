//
//  CreateReminderViewController.m
//  onething
//
//  Created by Dane Carr on 12-03-02.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import "CreateReminderViewController.h"
#import "RepeatDaySelectViewController.h"

@implementation CreateReminderViewController

@synthesize createReminderCallbackBlock = _createReminderCallbackBlock;
@synthesize deleteReminderCallbackBlock = _deleteReminderCallbackBlock;
@synthesize datePicker = _datePicker;
@synthesize cancelButton = _cancelButton;
@synthesize saveButton = _saveButton;
@synthesize tableView = _tableView;
@synthesize editingReminder = _editingReminder;
@synthesize reminder = _reminder;
@synthesize soundSwitch = _soundSwitch;
@synthesize deleteButton = _deleteButton;
@synthesize chevronImage = _chevronImage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelReminderCreation:)];
    self.saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(createReminder:)];
    
    UIImage *barButtonBackground = [[UIImage imageNamed:@"bar_button_save.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(14, 6, 14, 5)];
    UIImage *barButtonBackgroundHighlighted = [[UIImage imageNamed:@"bar_button_save_tap.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(14, 6, 14, 5)];
    
    [self.saveButton setBackgroundImage:barButtonBackground forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [self.saveButton setBackgroundImage:barButtonBackgroundHighlighted forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    
    [self.navigationItem setLeftBarButtonItem:self.cancelButton];
    [self.navigationItem setRightBarButtonItem:self.saveButton];
    
    [self.tableView setBackgroundColor:[UIColor tableBackgroundColour]];
    self.chevronImage = [UIImage imageNamed:@"table_chevron.png"];
        
    if (!self.editingReminder) {
        // Initialize a new reminder if not editing
        self.reminder = [[Reminder alloc] init];
        self.reminder.reminderID = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSinceReferenceDate]];
        self.reminder.version = 1;
        NSDateComponents *pickerDateComponents = [[NSCalendar currentCalendar] components:(NSMinuteCalendarUnit | NSHourCalendarUnit) fromDate:self.datePicker.date];
        self.reminder.repeatTime = pickerDateComponents;
        self.reminder.repeatDays = [[NSMutableArray alloc] initWithCapacity:7];
        for (int i = 0; i < 7; i++) {
            [self.reminder.repeatDays addObject:[NSNumber numberWithBool:NO]];
        }
        self.reminder.notificationSound = @"1thing-alert.caf";
    }
    else {
        // Create delete button if editing
        self.datePicker.date = [[NSCalendar currentCalendar] dateFromComponents:self.reminder.repeatTime];
        self.deleteButton = [[UIButton alloc] init];
        self.deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        UIImage *deleteButtonBackground = [[UIImage imageNamed:@"button_delete.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(22, 13, 22, 12)];
        UIImage *deleteButtonBackgroundHighlighted = [[UIImage imageNamed:@"button_delete_tap.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(22, 13, 22, 12)];
        
        [self.deleteButton setBackgroundImage:deleteButtonBackground forState:UIControlStateNormal];
        [self.deleteButton setBackgroundImage:deleteButtonBackgroundHighlighted forState:UIControlStateHighlighted];

        [self.deleteButton setTitle:@"Delete" forState:UIControlStateNormal];
        [self.deleteButton.titleLabel setFont:[UIFont boldSystemFontOfSize:18]];
        [self.deleteButton setTitleColor:[UIColor tableTextColour] forState:UIControlStateNormal];
        [self.deleteButton addTarget:self action:@selector(deleteReminder:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    // Initialize sound toggle switch
    self.soundSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
    [self.soundSwitch addTarget:self action:@selector(soundSwitchToggled:) forControlEvents:UIControlEventValueChanged];
    if (self.reminder.notificationSound) {
        self.soundSwitch.on = YES;
    }
    else {
        self.soundSwitch.on = NO;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Actions

- (void)cancelReminderCreation:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)createReminder:(id)sender 
{
    NSDateComponents *pickerDateComponents = [[NSCalendar currentCalendar] components:(NSMinuteCalendarUnit | NSHourCalendarUnit) fromDate:self.datePicker.date];
    self.reminder.repeatTime = pickerDateComponents;
    self.createReminderCallbackBlock(self.reminder);
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)deleteReminder:(id)sender 
{
    self.deleteReminderCallbackBlock(self.reminder.reminderID);
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)soundSwitchToggled:(id)sender 
{
    if (self.soundSwitch.on) {
        self.reminder.notificationSound = @"1thing-alert.caf";
    }
    else {
        self.reminder.notificationSound = nil;
    }
}

#pragma mark - Table View

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{    
    if (indexPath.section == 0 && indexPath.row == 0) {
        // Push view controller for selecting days to repeat on
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        RepeatDaySelectViewController *viewController = [[RepeatDaySelectViewController alloc] init];
        viewController.repeatDays = [NSMutableArray arrayWithArray:self.reminder.repeatDays];
        viewController.callbackBlock = ^(NSArray *repeatDays) {
            self.reminder.repeatDays = [NSMutableArray arrayWithArray:repeatDays];
            [self.tableView reloadData];
        };
        [self.navigationController pushViewController:viewController animated:YES];
    }
    else {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    return 44.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    if (section == 0) {
        return 2;
    }
    else if (section == 1) {
        return 1;
    }
    else {
        return 0;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EditReminderCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"EditReminderCell"];
        
        [cell.detailTextLabel setTextColor:[UIColor colorWithRed:93.0/255.0 green:106.0/255.0 blue:128.0/255.0 alpha:1.0]];
        [cell.detailTextLabel setFont:[UIFont systemFontOfSize:13.0]];
        
        [cell.textLabel setHighlightedTextColor:cell.textLabel.textColor];
        [cell.detailTextLabel setHighlightedTextColor:cell.detailTextLabel.textColor];
    }
    
    if (indexPath.section == 0) {
        
        TWGGroupedTableViewCellPosition position;
        
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"Repeat";
                cell.detailTextLabel.text = [self.reminder daysAsString];
                cell.accessoryView = [[UIImageView alloc] initWithImage:self.chevronImage];
                position = TWGGroupedTableViewCellPositionTop;
                break;
                
            case 1:
                cell.textLabel.text = @"Sound";
                cell.accessoryView = self.soundSwitch;
                position = TWGGroupedTableViewCellPositionBottom;
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                break;
                
            default:
                position = TWGGroupedTableViewCellPositionSingle;
                break;
        }
        
        TWGGroupedTableViewCellBackground *selectionBackground = [TWGGroupedTableViewCellBackground backgroundWithBorderColor:[UIColor tableSeparatorColour] fillColor:[UIColor tableSelectionColour] position:position];
        cell.selectedBackgroundView = selectionBackground;
    }
    else {
        self.deleteButton.frame = CGRectMake(10, 0, 280, 45);
        [cell.contentView addSubview:self.deleteButton];
        cell.backgroundView = [TWGGroupedTableViewCellBackground backgroundWithBorderColor:[UIColor clearColor] fillColor:[UIColor clearColor] position:TWGGroupedTableViewCellPositionSingle];
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    if (self.editingReminder) {
        return 2;
    }
    else {
        return 1;
    }
}

@end
