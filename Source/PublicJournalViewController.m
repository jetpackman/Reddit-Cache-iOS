//
//  SharedGratitudeViewController.m
//  onething
//
//  Created by Dane Carr on 12-03-30.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import "PublicJournalViewController.h"
#import "PublicGratitudeCell.h"
#import "LoadingTableViewCell.h"
#import "ShareGratitudeCell.h"
#import "Gratitude.h"
#import "GratitudeMapViewController.h"

@implementation PublicJournalViewController

@synthesize count = _count;
@synthesize bgImageView = _bgImageView;
@synthesize bgTapView = _bgTapView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"Public Journal"];
    
    self.gratitudeEditEnabled = NO;
    self.gratitudeShareDrawerEnabled = YES;
    self.onethingShareEnabled = NO;
    self.isMyGratitudesList = NO;
    
    [self.view setAccessibilityLabel:@"Shared Gratitude Screen"];
    
    [self configureNavBar];
    
}

-(void)configureNavBar
{
    [self setTitle:@"Public Journal"];
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navbutton_map.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(showPublicMap)];
    self.navigationItem.rightBarButtonItem = btn;
    [self.navigationItem.rightBarButtonItem setAccessibilityLabel:@"Map"];
    
}

- (void)showPublicMap
{
    GratitudeMapViewController *gratitudeMapViewController = [[GratitudeMapViewController alloc] init];
    gratitudeMapViewController.user = self.user;
    gratitudeMapViewController.mine = NO;
    
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle: @"Back" style: UIBarButtonItemStyleBordered target: nil action: nil];
    [[self navigationItem] setBackBarButtonItem: newBackButton];
    
    [self.navigationController pushViewController:gratitudeMapViewController animated:YES];
}

#pragma mark - Gratitudes

- (void)reloadGratitudes
{
    // Replace gratitude array with results
    if (self.updateOperation) {
        return;
    }
    
    [[OnethingClientAPI sharedClient] publicGratitudesWithApiKey:self.user.apiKey
                                                         perPage:GratitudesPerPage
                                                         startup:^(NSOperation *operation) {
                                                             self.updateOperation = operation;
                                                             if (self.noNetworkView) {
                                                                 [self.noNetworkView showLoadingIndicator];
                                                             }
                                                         }
                                                         success:^(NSArray *gratitudes, NSInteger count){
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
                                                                 
                                                                 // Show prompt when there are no gratitudes
                                                                 if ([gratitudes count] == 0 && [self.gratitudes count] == 0) {
                                                                     self.noGratitudesView = [[UIImageView alloc] initWithFrame:self.tableView.frame];
                                                                     [self.noGratitudesView insertSubview:self.bgImageView aboveSubview:self.tableView];
                                                                     [self.noGratitudesView insertSubview:self.bgTapView aboveSubview:self.bgImageView];
                                                                     [self.view insertSubview:self.noGratitudesView aboveSubview:self.tableView];
                                                                     
                                                                 }
                                                                 else {
                                                                     if (self.noGratitudesView) {
                                                                         // Remove prompt
                                                                         [self.noGratitudesView removeFromSuperview];
                                                                         self.noGratitudesView = nil;
                                                                     }
                                                                     NSMutableArray* gratitudeArray = [NSMutableArray arrayWithArray:gratitudes];
                                                                     
                                                                     // Inject the onboarding cell into the data
                                                                     if (![[NSUserDefaults standardUserDefaults] boolForKey:@"hasSeenShareTooltip"]){
                                                                         Gratitude* onboardingGratitude = [[Gratitude alloc] init];
                                                                         onboardingGratitude.gratitudeId = @"ONBOARDING";
                                                                         [gratitudeArray insertObject:onboardingGratitude atIndex:0];
                                                                     }
                                                                     
                                                                     self.gratitudes = [NSMutableArray arrayWithObject:gratitudeArray];
                                                                     self.count = count;
                                                                     [self.tableView reloadData];
                                                                 }
                                                             }];
                                                         }
                                                         failure:^(NSHTTPURLResponse *response, NSError *error){
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
    
    [[OnethingClientAPI sharedClient] publicGratitudesWithApiKey:self.user.apiKey
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
                                                                 self.count = count;
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

#pragma mark - Table

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"%d things to be grateful for", self.count];
}


#pragma mark - Onboarding

- (void)dismissOnboardingGratitudeCell:(NSNotification*)notification
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView beginUpdates];
    [[self.gratitudes objectAtIndex:0] removeObjectAtIndex:0];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    [self.tableView endUpdates];
    
    // Sync defaults so user doesn't see it again!
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:TRUE forKey:@"hasSeenShareTooltip"];
    [defaults synchronize];
}

@end
