//
//  RemindersViewController.m
//  onething
//
//  Created by Dane Carr on 12-03-01.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import "RemindersViewController.h"
#import "CreateReminderViewController.h"

@interface RemindersViewController (private)

- (void)cancelLocalNotificationsWithId:(NSString*)reminderId;
- (void)scheduleLocalNotifications:(NSArray*)notifications;
- (void)updateNSUserDefaults;

@end

@implementation RemindersViewController

@synthesize tableView = _tableView;
@synthesize createReminderButton = _createReminderButton;
@synthesize reminders = _reminders;
@synthesize dateFormatter = _dateFormatter;
@synthesize gregorianCalendar = _gregorianCalendar;
@synthesize chevronImage = _chevronImage;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"Reminders"];
    
    [self.tableView setBackgroundColor:[UIColor tableBackgroundColour]];
    self.chevronImage = [UIImage imageNamed:@"table_chevron.png"];
    
    self.createReminderButton = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStyleBordered target:self action:@selector(createReminder:)];
    [self.navigationItem setRightBarButtonItem:self.createReminderButton];
    [self.navigationItem.rightBarButtonItem setAccessibilityHint:@"Add a reminder"];
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    self.gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    // Load reminders from NSUserDefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *array = [[NSArray alloc] initWithArray:[defaults objectForKey:@"reminders"]];
    self.reminders = [[NSMutableArray alloc] initWithCapacity:array.count];
    for (int i = 0; i < array.count; i++) {
        [self.reminders addObject:[[Reminder alloc] initWithDictionary:[array objectAtIndex:i]]];
    }
    if (self.reminders.count == 0) {
        [self.tableView setHidden:YES];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)createReminder:(id)sender 
{
    // Create view controller
    CreateReminderViewController *viewController = [[CreateReminderViewController alloc] init];
    viewController.title = @"New Reminder";
    viewController.editingReminder = NO;
    viewController.createReminderCallbackBlock = ^(Reminder *reminder) {
        
        // Add reminder
        [self.reminders addObject:reminder];
        [self.tableView setHidden:NO];
        [self.tableView reloadData];
        
        // Update local notifications
        [self cancelLocalNotificationsWithId:reminder.reminderID];
        [self scheduleLocalNotifications:[reminder createLocalNotifications]];
        
        [self updateNSUserDefaults];
        NSLog(@"Reminders:\n%@", [[UIApplication sharedApplication] scheduledLocalNotifications]);
    };
    viewController.deleteReminderCallbackBlock = nil;
    
    // Embed viewController in UINavigationController and present it
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    [navigationController setModalPresentationStyle:UIModalTransitionStyleCoverVertical];
    self.modalDisplayed = YES;
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)cancelLocalNotificationsWithId:(NSString *)reminderId
{
    NSArray *scheduledNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    UILocalNotification *notification = nil;
    for (int i = 0; i < scheduledNotifications.count; i++) {
        notification = [scheduledNotifications objectAtIndex:i];
        if ([[notification.userInfo objectForKey:@"reminderId"] isEqualToString:reminderId]) {
            [[UIApplication sharedApplication] cancelLocalNotification:notification];
        }
    }
}

- (void)scheduleLocalNotifications:(NSArray *)notifications
{
    UIApplication *application = [UIApplication sharedApplication];
    UILocalNotification *notification = nil;
    for (int i = 0; i < notifications.count; i++) {
        notification = [notifications objectAtIndex:i];
        [application scheduleLocalNotification:notification];
    }
}

- (void)updateNSUserDefaults 
{
    // Get dictionary representations of all reminders and store in NSUserDefaults
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:self.reminders.count];
    for (int i = 0; i < self.reminders.count; i++) {
        [array addObject:[[self.reminders objectAtIndex:i] dictionaryRepresentation]];
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSArray arrayWithArray:array] forKey:@"reminders"];
    [defaults synchronize];
}

#pragma mark - TableView

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // Create viewController for editing reminder
    CreateReminderViewController *viewController = [[CreateReminderViewController alloc] init];
    viewController.title = @"Edit Reminder";
    viewController.editingReminder = YES;
    viewController.reminder = [self.reminders objectAtIndex:indexPath.row];
    viewController.createReminderCallbackBlock = ^(Reminder *reminder) {
        // Replace old reminder with updated one
        [self.reminders replaceObjectAtIndex:indexPath.row withObject:reminder];
        [self.tableView reloadData];
        
        // Update local notifications
        [self cancelLocalNotificationsWithId:reminder.reminderID];
        [self scheduleLocalNotifications:[reminder createLocalNotifications]];
        
        // Update stored reminder list
        [self updateNSUserDefaults];
    };
    viewController.deleteReminderCallbackBlock = ^(NSString* reminderId) {
        if(indexPath.row < [self.reminders count]) {
            // Animate reminder removal
            [self.tableView beginUpdates];
            [self.reminders removeObjectAtIndex:indexPath.row];
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationLeft];
            [self.tableView endUpdates];
        }
    
        if (self.reminders.count == 0) {
            // Show new reminder prompt
            [self.tableView setHidden:YES];
        }
        
        [self.tableView reloadData];
        
        // If reminders list is empty, ensure all local notifications are cleared
        if (self.reminders.count == 0) {
            [[UIApplication sharedApplication] cancelAllLocalNotifications];
        }
        else {
            // Otherwise selectively delete local notification
            [self cancelLocalNotificationsWithId:reminderId];
        }
        
        // Update stored reminder list
        [self updateNSUserDefaults];
        NSLog(@"Reminders:\n%@", [[UIApplication sharedApplication] scheduledLocalNotifications]);
    };
    
    // Embed viewController in UINavigationController and present it
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    [navigationController setModalPresentationStyle:UIModalTransitionStyleCoverVertical];
    self.modalDisplayed = YES;
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.reminders.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    return 50.0f;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reminderCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"reminderCell"];
        [cell.textLabel setTextColor:[UIColor tableTextColour]];
        [cell.detailTextLabel setTextColor:[UIColor colorWithRed:93.0/255.0 green:106.0/255.0 blue:128.0/255.0 alpha:1.0]];
        
        [cell.textLabel setHighlightedTextColor:cell.textLabel.textColor];
        [cell.detailTextLabel setHighlightedTextColor:cell.detailTextLabel.textColor];
    }
    
    TWGGroupedTableViewCellPosition position;
    
    if (self.reminders.count == 1) {
        position = TWGGroupedTableViewCellPositionSingle;
    }
    else if (indexPath.row == 0) {
        position = TWGGroupedTableViewCellPositionTop;
    }
    else if (indexPath.row == self.reminders.count - 1) {
        position = TWGGroupedTableViewCellPositionBottom;
    }
    else {
        position = TWGGroupedTableViewCellPositionMiddle;
    }
    
    TWGGroupedTableViewCellBackground *selectionBackground = [TWGGroupedTableViewCellBackground backgroundWithBorderColor:[UIColor tableSeparatorColour] fillColor:[UIColor tableSelectionColour] position:position];
    [cell setSelectedBackgroundView:selectionBackground];
    
    Reminder *reminder = [self.reminders objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [self.dateFormatter stringFromDate:[self.gregorianCalendar dateFromComponents:reminder.repeatTime]];
    cell.detailTextLabel.text = [[self.reminders objectAtIndex:indexPath.row] daysAsString];
    if ([cell.detailTextLabel.text isEqualToString:@"Never"]) {
        cell.detailTextLabel.text = @"";
    }
    cell.accessoryView = [[UIImageView alloc] initWithImage:self.chevronImage];
    return cell;
}



@end
