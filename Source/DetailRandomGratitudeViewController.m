//
//  DetailRandomGratitudeViewController.m
//  onething
//
//  Created by Chris Taylor on 12-06-28.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import "DetailRandomGratitudeViewController.h"

@implementation DetailRandomGratitudeViewController

@synthesize gratitude = _gratitude;

- (void) viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"Random Gratitude"];
    [self.view setAccessibilityLabel:@"Random Gratitude Screen"];
    
    self.gratitudeShareDrawerEnabled = YES;
    self.onethingShareEnabled = YES;
    self.gratitudeEditEnabled = NO;
    self.drawerSwipeEnabled = NO;
    
    [self.view setAccessibilityLabel:@"Random Gratitude - Detail View Screen"];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // Clear/allocate arrays
    self.gratitudes = [[NSMutableArray alloc] init];
    self.gratitudeListSections = [[NSMutableArray alloc] init];
    [self.tableView reloadData];
    [self configureWithGratitude:self.gratitude];
}

- (void) configureWithGratitude:(Gratitude*)gratitude
{
    // Begin table view animations
    [self.tableView beginUpdates];
    
    // Table needs a new section
    [self.gratitudes insertObject:[NSMutableArray arrayWithObject:gratitude] atIndex:0];
    [self.gratitudeListSections insertObject:@"" atIndex:0];
    [self.tableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    
    // Update table
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    // End table animations
    [self.tableView endUpdates];
    
    // Scroll to gratitude
    [self.tableView scrollToRowAtIndexPath:0 atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
    [self openShareDrawerAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
}


- (void) reloadGratitudes {
    self.lastUpdatedAt = [NSDate date];
    [self.refreshView finishedLoading];
    return;
}

- (void) loadMoreGratitudes {
    return;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {

    return @"";
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {

    return 0;
}

@end
