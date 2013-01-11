//
//  GratitudesForTopWordViewController.m
//  onething
//
//  Created by Anthony Wong on 12-05-10.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import "GratitudesForTopWordViewController.h"
#import "LoadingTableViewCell.h"

@implementation GratitudesForTopWordViewController
@synthesize topWord = _topWord;
@synthesize topWordCount = _topWordCount;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"Top Words"];
    self.gratitudeShareDrawerEnabled = YES;
    self.onethingShareEnabled = YES;
    self.gratitudeEditEnabled = NO;
    self.drawerSwipeEnabled = NO;
}

#pragma mark - Table Overloads
- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if([self.topWordCount intValue] == 1) {
        return [NSString stringWithFormat:@"You mentioned \"%@\" %@ time.", self.topWord, self.topWordCount];
    } else {
        return [NSString stringWithFormat:@"You mentioned \"%@\" %@ times.", self.topWord, self.topWordCount];

    }
}

#pragma mark - Gratitudes

- (void)reloadGratitudes 
{
    // Only one update operation at a time
    if (self.updateOperation) {
        return;
    }
    
    [[OnethingClientAPI sharedClient] gratitudesForTopWord: self.topWord
                                                 apiKey:self.user.apiKey 
                                                perPage:GratitudesPerPage 
                                                startup:^(NSOperation *operation) {
                                                    self.updateOperation = operation;
                                                    if (self.noNetworkView) {
                                                        [self.noNetworkView showLoadingIndicator];
                                                    }
                                                } 
                                                success:^(NSArray *gratitudes, int count) {
                                                    // Network request was successful
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
    [[OnethingClientAPI sharedClient] gratitudesForTopWord:self.topWord
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

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.gratitudes) {
        if (self.shareCellOpen && indexPath.row == self.shareCellIndexPath.row && indexPath.section == self.shareCellIndexPath.section) {
            // Dequeue a share cell
            ShareGratitudeCell *cell = [self.tableView dequeueReusableCellWithIdentifier:ShareGratitudeCellIdentifier];
            
            if (!cell) {
                // Create new share cell
                UIViewController *viewController = [[UIViewController alloc] initWithNibName:@"ShareGratitudeCell" bundle:nil];
                cell = (ShareGratitudeCell*) viewController.view;
                
                [cell.backgroundImage setImage:[[UIImage imageNamed:@"bg_share_drawer.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(4, 17, 3, 16)]];
                
                [cell.emailShareButton addTarget:self action:@selector(shareEmail:) forControlEvents:UIControlEventTouchUpInside];
                [cell.smsShareButton addTarget:self action:@selector(shareSms:) forControlEvents:UIControlEventTouchUpInside];
                [cell.twitterShareButton addTarget:self action:@selector(shareTwitter:) forControlEvents:UIControlEventTouchUpInside];
                [cell.facebookShareButton addTarget:self action:@selector(shareFacebook:) forControlEvents:UIControlEventTouchUpInside];
                if(self.onethingShareEnabled) {
                    [cell.onethingShareButton addTarget:self action:@selector(shareOnething:) forControlEvents:UIControlEventTouchUpInside];
                } else {
                    cell.onethingShareButton.hidden = YES;
                    cell.emailShareButton.frame = CGRectMake(39, cell.emailShareButton.frame.origin.y, cell.emailShareButton.frame.size.width, cell.emailShareButton.frame.size.height);
                    cell.smsShareButton.frame = CGRectMake(105, cell.smsShareButton.frame.origin.y, cell.smsShareButton.frame.size.width, cell.smsShareButton.frame.size.height);
                    cell.twitterShareButton.frame = CGRectMake(171, cell.twitterShareButton.frame.origin.y, cell.twitterShareButton.frame.size.width, cell.twitterShareButton.frame.size.height);
                    cell.facebookShareButton.frame = CGRectMake(237, cell.facebookShareButton.frame.origin.y, cell.facebookShareButton.frame.size.width, cell.facebookShareButton.frame.size.height);
                }
            }
            
            // Set buttons depending on services available
            if(self.onethingShareEnabled) {
                cell.onethingShareButton.enabled = ([[[self.gratitudes objectAtIndex:indexPath.section] objectAtIndex:(indexPath.row - 1)] isPublic] ? NO : YES);
            }
            cell.emailShareButton.enabled = ([MFMailComposeViewController canSendMail] ? YES : NO);
            cell.smsShareButton.enabled = ([MFMessageComposeViewController canSendText] ? YES : NO);
            cell.twitterShareButton.enabled = ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter] ? YES : NO);
            cell.facebookShareButton.enabled = YES;
            
            return cell;
        }
        else {
            // Dequeue a gratitude cell
            if(self.isMyGratitudesList)
            {
                MyGratitudeCell *cell = [self.tableView dequeueReusableCellWithIdentifier:MyGratitudeCellIdentifier];
                
                if (!cell) {
                    // Create new gratitude cell
                    UIViewController* viewController = [[UIViewController alloc] initWithNibName:@"MyGratitudeCell" bundle:nil];
                    cell = (MyGratitudeCell*) viewController.view;
                    UIView *backgroundView = [[UIView alloc] init];
                    [backgroundView setBackgroundColor:[UIColor tableBackgroundColour]];
                    cell.backgroundView = backgroundView;
                    
                    UIImageView *selectedBackgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"bg_gratitude_cell_select.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(4, 4, 4, 4)]];
                    selectedBackgroundView.frame = CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height);
                    cell.selectedBackgroundView = selectedBackgroundView;
                }
                // Tell cell to configure itself
                return [cell configureWithGratitude:[[self.gratitudes objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] AndTopWord:self.topWord];
            }
        }
    }
    else {
        // Show loading cell if gratitudes array is uninitialized
        LoadingTableViewCell *cell = (LoadingTableViewCell*) [self.tableView dequeueReusableCellWithIdentifier:@"LoadingTableViewCell"];
        if (!cell) {
            UIViewController *viewController = [[UIViewController alloc] initWithNibName:@"LoadingTableViewCell" bundle:nil];
            cell = (LoadingTableViewCell*) viewController.view;
        }
        
        [cell.activityView startAnimating];
        return cell;
    }
    return nil;
}



@end
