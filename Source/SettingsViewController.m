//
//  SettingsViewController.m
//  onething
//
//  Created by Dane Carr on 12-03-01.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import "SettingsViewController.h"
#import "PersonalDetailsViewController.h"
#import "RemindersViewController.h"
#import "ChangeBackgroundViewController.h"
#import "TWGMenuController.h"
#import "PrivacyViewController.h"

@implementation SettingsViewController

@synthesize user = _user;
@synthesize tableView = _tableView;
@synthesize chevronImage = _chevronImage;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"Settings"];
    
    [self.tableView setBackgroundColor:[UIColor tableBackgroundColour]];
    self.chevronImage = [UIImage imageNamed:@"table_chevron.png"];
    
    
    UISwipeGestureRecognizer *rightSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)];
    rightSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:rightSwipeGestureRecognizer];
    [self.view setAccessibilityLabel:@"Settings Screen"];

    
    self.pushedViewControllers = [NSMutableArray array];
    
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle: @"Back" style: UIBarButtonItemStyleBordered target: nil action: nil];
    [[self navigationItem] setBackBarButtonItem: newBackButton];
    
    
}

- (void)swipeRight:(UISwipeGestureRecognizer*)recognizer
{
    [self swipe:recognizer direction:UISwipeGestureRecognizerDirectionRight];
}

- (void)swipe:(UISwipeGestureRecognizer*)recognizer direction:(UISwipeGestureRecognizerDirection)direction 
{
    if (recognizer && recognizer.state == UIGestureRecognizerStateEnded) {
        if (direction == UISwipeGestureRecognizerDirectionRight) {
            // Show drawer menu for right swipe
            [(TWGMenuController*)self.parentViewController.parentViewController showLeftDrawer];
            return;
        }
    }
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.pushedViewControllers removeAllObjects];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 4;
            break;
        case 1:
            return 1;
            break;
        default:
            return 0;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    return 48.f;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SettingsCell"];
    [cell.textLabel setTextColor:[UIColor tableTextColour]];
    TWGGroupedTableViewCellPosition position = TWGGroupedTableViewCellPositionTop;
    
    if ([indexPath section] == 0) {
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"Personal Details";
                position = TWGGroupedTableViewCellPositionTop;
                break;
                
            case 1:
                cell.textLabel.text = @"Reminders";
                position = TWGGroupedTableViewCellPositionMiddle;
                break;
                
            case 2:
                cell.textLabel.text = @"Change Background";
                position = TWGGroupedTableViewCellPositionMiddle;
                break;
                
            case 3:
                cell.textLabel.text = @"Privacy";
                position = TWGGroupedTableViewCellPositionBottom;
                break;
                
            default:
                position = TWGGroupedTableViewCellPositionMiddle;
                break;
        }
        cell.accessoryView = [[UIImageView alloc] initWithImage:self.chevronImage]; 
    } else {
        // Only one row in this section
        cell.textLabel.text = @"Sign Out";
        cell.textLabel.textAlignment =  NSTextAlignmentCenter;
        [cell setAccessibilityLabel:cell.textLabel.text];
        
    }

    TWGGroupedTableViewCellBackground *selectionBackgroundView = [TWGGroupedTableViewCellBackground backgroundWithBorderColor:[UIColor tableSeparatorColour] fillColor:[UIColor tableSelectionColour] position:position];
    [cell setSelectedBackgroundView:selectionBackgroundView];
    
    [cell.textLabel setHighlightedTextColor:cell.textLabel.textColor];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UIViewController *viewController;
    
    if ([indexPath section] == 0) {
        switch (indexPath.row) {
            case 0:
                viewController = [[PersonalDetailsViewController alloc] initWithUser:self.user];
                break;
            case 1:
                viewController = [[RemindersViewController alloc] init];
                break;
                
            case 2:
                viewController = [[ChangeBackgroundViewController alloc] init];
                break;
            case 3:
                viewController = [[PrivacyViewController alloc] init];
                break;
                
            default:
                return;
                break;
        }
        
        [self.pushedViewControllers addObject:viewController];
        [self.navigationController pushViewController:viewController animated:YES];
    } else {
        // Only one row in this section
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:NO forKey:UserDefaultsLoggedIn];
        [defaults synchronize];
        self.modalDisplayed = NO;
        
        // Clear local notifications
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        [self dismissViewControllerAnimated:YES completion:nil];
    }

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

@end
