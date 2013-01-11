//
//  GratitudesForDateViewController.m
//  onething
//
//  Created by Dane Carr on 12-03-28.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import "GratitudesForDateViewController.h"
#import "LoadingTableViewCell.h"
#import "ShareGratitudeCell.h"
#import "CreateGratitudeViewController.h"

@implementation GratitudesForDateViewController

@synthesize date = _date;
@synthesize dateFormatter = _dateFormatter;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"Calendar"];
    UIImage *image = [UIImage imageNamed: @"calendar.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage: image];
    self.navigationItem.titleView = imageView;
    self.gratitudeShareDrawerEnabled = YES;
    self.onethingShareEnabled = YES;
    self.gratitudeEditEnabled = NO;
    self.drawerSwipeEnabled = NO;
}

#pragma mark - Gratitudes

- (void)reloadGratitudes 
{
    // Only one update operation at a time
    if (self.updateOperation) {
        return;
    }
        
    [[OnethingClientAPI sharedClient] gratitudesForDate:[self.dateFormatter stringFromDate:self.date] 
                                                 apiKey:self.user.apiKey 
                                                perPage:GratitudesPerPage 
                                                startup:^(NSOperation *operation) {
                                                    self.updateOperation = operation;
                                                    if (self.noNetworkView) {
                                                        [self.noNetworkView showLoadingIndicator];
                                                    }
                                                } 
                                                success:^(NSArray *gratitudes, int count) {
                                                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                                        
                                                        if (self.noNetworkView) {
                                                            [UIView animateWithDuration:0.5 animations:^{
                                                                self.noNetworkView.alpha = 0;
                                                            } completion:^(BOOL finished) {
                                                                [self.noNetworkView removeFromSuperview];
                                                                self.noNetworkView = nil;
                                                            }];
                                                        }
                                                        if (self.tableView.tableHeaderView) {
                                                            self.tableView.tableHeaderView = nil;
                                                        }
                                                        self.gratitudes = [NSMutableArray arrayWithObject:[NSMutableArray arrayWithArray:gratitudes]];
                                                        [self.tableView reloadData];
                                                    }];
                                                } 
                                                failure:^(NSHTTPURLResponse *response, NSError *error) {
                                                    NSLog(@"[ERROR] Failed to load gratitudes: %@ %@", [response debugDescription], [error userInfo]);
                                                    
                                                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                                        if (!self.gratitudes) {
                                                            if (!self.noNetworkView) {
                                                                self.noNetworkView = (NetworkStatusView*)[[UIViewController alloc] initWithNibName:@"NetworkStatusView" bundle:nil].view;
                                                                [self.noNetworkView.retryButton addTarget:self action:@selector(reloadGratitudes) forControlEvents:UIControlEventTouchUpInside];
                                                                self.noNetworkView.alpha = 0;
                                                                [self.view insertSubview:self.noNetworkView aboveSubview:self.tableView];
                                                                [UIView animateWithDuration:0.5 animations:^{
                                                                    self.noNetworkView.alpha = 1;
                                                                } completion:^(BOOL finished) {
                                                                    [self.noNetworkView hideLoadingIndicator];
                                                                }];
                                                            }
                                                            else {
                                                                [self.noNetworkView hideLoadingIndicator];
                                                            }
                                                        }
                                                        else {
                                                            if (!self.tableView.tableHeaderView) {
                                                                self.tableView.tableHeaderView = [[UIViewController alloc] initWithNibName:@"NetworkStatusHeader" bundle:nil].view;
                                                            }
                                                        }
                                                    }];
                                                } 
                                             completion:^{
                                                 self.updateOperation = nil;
                                                 self.lastUpdatedAt = [NSDate date];
                                                 [self.refreshView finishedLoading];
                                                 
                                             }];
}

- (void)loadMoreGratitudes 
{
    // Update gratitude array with results
    if (self.updateOperation) {
        return;
    }
    
    [[OnethingClientAPI sharedClient] gratitudesForDate:[self.dateFormatter stringFromDate:self.date] 
                                                 apiKey:self.user.apiKey 
                                               anchorId:[((Gratitude*)[[self.gratitudes lastObject] lastObject]).gratitudeId intValue]                                                       
                                                perPage:GratitudesPerPage 
                                                startup:^(NSOperation *operation){
                                                    self.updateOperation = operation;
                                                } 
                                                success:^(NSArray *gratitudes, NSInteger count) {
                                                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                                        if (self.gratitudes) {
                                                            [[self.gratitudes lastObject] addObjectsFromArray:gratitudes];
                                                        }
                                                        else {
                                                            self.gratitudes = [NSArray arrayWithObject:[NSMutableArray arrayWithArray:gratitudes]];
                                                        }
                                                        [self.tableView reloadData];
                                                    }];
                                                } 
                                                failure:^(NSHTTPURLResponse *response, NSError *error)  {
                                                    NSLog(@"[ERROR] Failed to load gratitudes: %@ %@", [response debugDescription], [error userInfo]);
                                                } 
                                             completion:^{
                                                 self.updateOperation = nil;
                                             }];
}


- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.dateFormatter stringFromDate:self.date];
}

@end
