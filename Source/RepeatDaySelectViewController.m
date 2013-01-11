//
//  RepeatDaySelectViewController.m
//  onething
//
//  Created by Dane Carr on 12-03-06.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import "RepeatDaySelectViewController.h"

@implementation RepeatDaySelectViewController

@synthesize tableView = _tableView;
@synthesize repeatDays = _repeatDays;
@synthesize dateFormatter = _dateFormatter;
@synthesize callbackBlock = _callbackBlock;

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
    self.title = @"Repeat";
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.tableView setBackgroundColor:[UIColor tableBackgroundColour]];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.callbackBlock(self.repeatDays);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return 7;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    return 44.0f;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RepeatDaySelectCell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"RepeatDaySelectCell"];
        [cell.textLabel setHighlightedTextColor:cell.textLabel.textColor];
    }
    
    TWGGroupedTableViewCellPosition position;
    if (indexPath.row == 0) {
        position = TWGGroupedTableViewCellPositionTop;
    }
    else if (indexPath.row == 6) {
        position = TWGGroupedTableViewCellPositionBottom;
    }
    else {
        position = TWGGroupedTableViewCellPositionMiddle;
    }
    
    TWGGroupedTableViewCellBackground *selectionBackground = [TWGGroupedTableViewCellBackground backgroundWithBorderColor:[UIColor tableSeparatorColour] fillColor:[UIColor tableSelectionColour] position:position];
    [cell setSelectedBackgroundView:selectionBackground];
    
    if ([[self.repeatDays objectAtIndex:indexPath.row] boolValue]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    cell.textLabel.text = [NSString stringWithFormat:@"Every %@", [[self.dateFormatter weekdaySymbols] objectAtIndex:indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell.accessoryType == UITableViewCellAccessoryNone) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.repeatDays replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:YES]];
    }
    else if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [self.repeatDays replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:NO]];
    }
}

@end
