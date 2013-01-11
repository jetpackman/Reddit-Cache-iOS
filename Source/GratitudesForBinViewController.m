//
//  GratitudesForBinViewController.m
//  onething
//
//  Created by Anthony Wong on 12-05-11.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import "GratitudesForBinViewController.h"

@implementation GratitudesForBinViewController

@synthesize mine = _mine;
@synthesize gratCount = _gratCount;
@synthesize publicGratCount = _publicGratCount;
@synthesize neighbourhood = _neighbourhood;
@synthesize city = _city;
@synthesize location = _location;
@synthesize gratitudes = _gratitudes;


- (void)viewDidLoad
{
    [super viewDidLoad];

    if (self.mine) {
        self.gratCount == 1 ? [self setTitle:@"My Gratitude"] : [self setTitle:@"My Gratitudes"];
    } else {
        self.gratCount == 1 ? [self setTitle:@"Someone's Gratitude"] : [self setTitle:@"Others' Gratitudes"];
    }
    
    if (self.mine) {
        self.gratitudeEditEnabled = NO;
        self.gratitudeEditEnabled = YES;
        self.gratitudeShareDrawerEnabled = YES;
        self.onethingShareEnabled = YES;
    } else {
        self.gratitudeEditEnabled = NO;
        self.gratitudeShareDrawerEnabled = YES;
        self.onethingShareEnabled = NO;
        self.isMyGratitudesList = NO;
    }
    
    self.drawerSwipeEnabled = NO;
    
    self.gratitudes = [NSMutableArray arrayWithObject:[[NSMutableArray alloc] init ]];
}

- (void)shareOnething:(id)sender 
{
    [super shareOnething:sender];
    self.publicGratCount = self.publicGratCount +1;
    [self.tableView reloadData];
}

#pragma mark - Table

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    // Always should be only one section, that is the section of the pin.
    NSString *retVal = nil;
    
    if (self.mine) {
        retVal = [NSString stringWithFormat:@"You shared %d of %d gratitudes you wrote here", self.publicGratCount, self.gratCount];
    } else {
        retVal = [NSString stringWithFormat:@"People shared %d of %d gratitudes written here", self.publicGratCount, self.gratCount];
    }
    return retVal;
}
#pragma mark - Gratitudes

- (void)reloadGratitudes
{
    // Replace gratitude array with results
    if (self.updateOperation) {
        return;
    }
    
    [[OnethingClientAPI sharedClient] gratitudesForNeighbourhood:self.neighbourhood
                                                            city:self.city
                                                          apiKey:self.user.apiKey
                                                          isMine:self.mine
                                                         perPage:GratitudesPerPage
                                                    startup:^(NSOperation *operation) {
                                                        self.updateOperation = operation;
                                                        if (self.noNetworkView) {
                                                            [self.noNetworkView showLoadingIndicator];
                                                        }
                                                    }  success:^(NSArray *gratitudes, int count){
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
                                                    }  failure:^(NSHTTPURLResponse *response, NSError *error){
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
                                                    }  completion:^{
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
    [[OnethingClientAPI sharedClient] gratitudesForNeighbourhood:self.neighbourhood
                                                            city:self.city
                                                          apiKey:self.user.apiKey 
                                                        anchorId:[((Gratitude*)[[self.gratitudes lastObject] lastObject]).gratitudeId intValue] 
                                                          isMine:self.mine
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

@end
