//
//  TopWordsViewController.m
//  onething
//
//  Created by Anthony Wong on 12-05-09.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import "TopWordsViewController.h"
#import "OnethingClientAPI.h"
#import "OnethingConstants.h"
#import "GratitudesForTopWordViewController.h"
#import "LoadingTableViewCell.h"
#import "WordCloudViewController.h"

@implementation TopWordsViewController
@synthesize noGratitudesView = _noGratitudesView;
@synthesize tableView = _tableView;
@synthesize user = _user;
@synthesize updateOperation = _updateOperation;
@synthesize topWords = _topWords;
@synthesize noNetworkView = _noNetworkView;
@synthesize refreshView = _refreshView;
@synthesize lastUpdated = _lastUpdated;
@synthesize swipeRemoveView = _swipeRemoveView;
@synthesize swipeRemoveViewVisible = _swipeRemoveViewVisible;
@synthesize createGratitudeButton = _createGratitudeButton;
@synthesize swipeRemoveCell = _swipeRemoveCell;
@synthesize animatingSwipeView = _animatingSwipeView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self configureNavBar];
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.pushedViewControllers = [NSMutableArray array];
    
    [self.tableView setBackgroundColor:[UIColor tableBackgroundColour]];
    self.refreshView = [[PullToRefreshView alloc] initWithScrollView:self.tableView];
    self.refreshView.delegate = self;
    self.refreshView.backgroundColor = [UIColor clearColor];
    [self.tableView addSubview:self.refreshView];
    self.swipeRemoveViewVisible = NO;
    [self createGestureRecognizers];
    [self.view setAccessibilityLabel:@"Top Words Screen"];
}

- (void)viewDidUnload
{
    self.tableView = nil;
    [self setCreateGratitudeButton:nil];
    [super viewDidUnload];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.swipeRemoveViewVisible) {
        [self hideSwipeRemoveView:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.pushedViewControllers removeAllObjects];
    [self reloadTopWords];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)configureNavBar
{
    [self setTitle:@"Top Words"];
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navbutton_cloud.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(showWordCloud)];
    self.navigationItem.rightBarButtonItem = btn;
    
    [self.navigationItem.rightBarButtonItem setAccessibilityLabel:@"Word Cloud"];
    
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle: @"Back" style: UIBarButtonItemStyleBordered target: nil action: nil];
    [[self navigationItem] setBackBarButtonItem: newBackButton];
}

- (void)showWordCloud
{
    WordCloudViewController *wordCloudViewController = [[WordCloudViewController alloc] init];
    wordCloudViewController.user = self.user;
    
    [[self navigationController] pushViewController:wordCloudViewController animated:YES];
    
}

- (void)createGestureRecognizers
{
    UISwipeGestureRecognizer *rightSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)];
    rightSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:rightSwipeGestureRecognizer];
    
    UISwipeGestureRecognizer *leftSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)];
    leftSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:leftSwipeGestureRecognizer];
    
    UISwipeGestureRecognizer *buttonSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(createGratitudeSwiped:)];
    buttonSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
    [self.createGratitudeButton addGestureRecognizer:buttonSwipeGestureRecognizer];
    
    // Use SwipeViewEdit for simplicity. Change button text to Remove.
    UIViewController *vc = [[UIViewController alloc] initWithNibName:@"SwipeEditView" bundle:nil];
    self.swipeRemoveView = (SwipeEditView*) vc.view;
    [self.swipeRemoveView.editButton setTitle:@"Remove" forState:UIControlStateNormal];
    [self.swipeRemoveView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_tile.png"]]];
    [self.swipeRemoveView.editButton addTarget:self action:@selector(removeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.swipeRemoveView.editButton setBackgroundImage:[[UIImage imageNamed:@"button_edit.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 5, 14, 5)] forState:UIControlStateNormal];
    
    [self.swipeRemoveView.backgroundImageView setImage:[[UIImage imageNamed:@"bg_inside_shadow.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(4, 4, 4, 4)]];
    [self.swipeRemoveView.backgroundImageView setAlpha:0.75];
}

- (void)createGratitudeSwiped:(UISwipeGestureRecognizer*)reconigzer
{
    [self createGratitude:reconigzer];
}


- (IBAction)createGratitude:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:CreatingGratitudeNotification object:nil];

}

#pragma mark Top Words

- (void)reloadTopWords 
{
    if (self.updateOperation) {
        return;
    }
    
    [[OnethingClientAPI sharedClient] topWordsWithApiKey:self.user.apiKey
                                                 startup:^(NSOperation *operation) {
                                                     self.updateOperation = operation;
                                                     if (self.noNetworkView) {
                                                         [self.noNetworkView showLoadingIndicator];
                                                     } 
                                                 }
                                                 success:^(NSArray *topWords) {
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
                                                         if ([topWords count] == 0 && [self.topWords count] == 0) {
                                                             self.noGratitudesView = [[UIImageView alloc] initWithFrame:self.tableView.frame];
                                                             self.noGratitudesView.image = [UIImage imageNamed:@"no_gratitudes_view.png"];
                                                             [self.view insertSubview:self.noGratitudesView aboveSubview:self.tableView];
                                                         }
                                                         else {
                                                             if (self.noGratitudesView) {
                                                                 // Remove prompt
                                                                 [self.noGratitudesView removeFromSuperview];
                                                                 self.noGratitudesView = nil;
                                                             }
                                                             self.topWords = [NSMutableArray arrayWithArray:topWords];
                                                             [self.tableView reloadData];
                                                         }
                                                     }];
                                                 }
                                                 failure:^(NSHTTPURLResponse *response, NSError *error) {
                                                     NSLog(@"[ERROR] Failed to reload topWords: %@ %@", [response debugDescription], [error userInfo]);
                                                     [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                                         if (!self.topWords) {
                                                             if (!self.noNetworkView) {
                                                                 self.noNetworkView = (NetworkStatusView*)[[UIViewController alloc] initWithNibName:@"NetworkStatusView" bundle:nil].view;
                                                                 [self.noNetworkView.retryButton addTarget:self action:@selector(reloadTopWords) forControlEvents:UIControlEventTouchUpInside];
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
                                                     self.lastUpdated = [NSDate date];
                                                     [self.refreshView finishedLoading];
                                                 }];
}

#pragma mark - Table
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!self.topWords) {
        return 1;
    }
    return self.topWords.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TopWordsCell *cell = [self.tableView dequeueReusableCellWithIdentifier:TopWordsCellIdentifier];
    if (self.topWords) {
        if (!cell) {
            UIViewController *viewController = [[UIViewController alloc] initWithNibName:@"TopWordsCell" bundle:nil];
            cell = (TopWordsCell*) viewController.view;
            
            [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
            
            UIView *backgroundView = [[UIView alloc] init];
            [backgroundView setBackgroundColor:[UIColor tableBackgroundColour]];
            [cell setBackgroundView:backgroundView];
            
            UIView *selectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
            [selectionView setBackgroundColor:[UIColor tableSelectionColour]];
            [cell setSelectedBackgroundView:selectionView];
        }
        
        return [cell configureCellForTopWord:[self.topWords objectAtIndex:indexPath.row]];
    } else {
        // Show loading cell if gratitudes array is uninitialized
        LoadingTableViewCell *cell = (LoadingTableViewCell*) [self.tableView dequeueReusableCellWithIdentifier:@"LoadingTableViewCell"];
        if (!cell) {
            UIViewController *viewController = [[UIViewController alloc] initWithNibName:@"LoadingTableViewCell" bundle:nil];
            cell = (LoadingTableViewCell*) viewController.view;
        }
        
        [cell.activityView startAnimating];
        return cell;
    }

    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Hide remove view before showing share cell
    if (self.swipeRemoveViewVisible) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        [self hideSwipeRemoveView:YES];
        return;
    }
    
    GratitudesForTopWordViewController* viewController = [[GratitudesForTopWordViewController alloc] initWithNibName:@"GratitudesForTopWordViewController" bundle:nil];
    
    NSMutableDictionary* topWord = [self.topWords objectAtIndex:[indexPath row]];
    viewController.user = self.user;
    viewController.topWord = [topWord objectForKey:@"word"];
    viewController.topWordCount = [topWord objectForKey:@"count"];
    
    [self.pushedViewControllers addObject:viewController];
    [self.navigationController pushViewController:viewController animated:YES];
    
    
}

- (void)pullToRefreshViewShouldRefresh:(PullToRefreshView *)view 
{
    [self reloadTopWords];
}

- (NSDate*)pullToRefreshViewLastUpdated:(PullToRefreshView *)view 
{
    return self.lastUpdated;
}

- (void)removeButtonPressed:(id)sender
{
    if (self.swipeRemoveViewVisible) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:self.swipeRemoveCell];
        // Make api call to remove word from Top Words
        [[OnethingClientAPI sharedClient] removeTopWordWithApiKey:self.user.apiKey
                                                           wordId:[[self.topWords objectAtIndex:indexPath.row] valueForKey:@"id"]
                                                          startup:^(NSOperation *operation) {
                                                              self.updateOperation = operation;
                                                              if (self.noNetworkView) {
                                                                  [self.noNetworkView showLoadingIndicator];
                                                              } 
                                                          }
         
                                                          success:^{        
                                                              // Remove word from table
                                                              [self hideSwipeRemoveView:YES completion:^{
                                                                  if (indexPath.row < [self.topWords count]) {
                                                                      [self.topWords removeObjectAtIndex:indexPath.row];
                                                                      [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
                                                                  }
                                                              }];  
                                                          }
                                                          failure:^(NSHTTPURLResponse *response, NSError *error) {
                                                              NSLog(@"[ERROR] Failed to remove top word: %@ %@", [response debugDescription], [error userInfo]);
                                                          }
                                                       completion:^{                                            
                                                           self.updateOperation = nil;
    } ];
    }
}

#pragma  mark - Swipe

// Swipe gesture recognizer methods
- (void)swipeLeft:(UISwipeGestureRecognizer*)recognizer 
{
    if (self.topWords) {
        [self swipe:recognizer direction:UISwipeGestureRecognizerDirectionLeft];
    }
}

- (void)swipeRight:(UISwipeGestureRecognizer*)recognizer
{
    if (self.topWords) {
        [self swipe:recognizer direction:UISwipeGestureRecognizerDirectionRight];
    }
}

- (void)swipe:(UISwipeGestureRecognizer*)recognizer direction:(UISwipeGestureRecognizerDirection)direction 
{
    if (recognizer && recognizer.state == UIGestureRecognizerStateEnded) {

        if (self.swipeRemoveViewVisible) {
            // Swiping when a cell has already been swiped hides the swipe view
            [self hideSwipeRemoveView:YES];
            return;
        }
        
        if (direction == UISwipeGestureRecognizerDirectionRight) {
            // Show drawer menu for right swipe
            [(TWGMenuController*)self.parentViewController.parentViewController showLeftDrawer];
            return;
        }
        
        // Find cell that was swiped on
        CGPoint location = [recognizer locationInView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
        TopWordsCell *cell = (TopWordsCell*)[self.tableView cellForRowAtIndexPath:indexPath];
        
        [self showSwipeRemoveViewFor:cell direction:direction];
    }
}

- (void)showSwipeRemoveViewFor:(TopWordsCell*)cell direction:(UISwipeGestureRecognizerDirection)direction 
{
    self.swipeRemoveViewVisible = YES;
    // Move swipeRemoveView to below cell
    self.swipeRemoveView.frame = cell.frame;
    self.swipeRemoveView.hidden = NO;
    
    // Position drop shadow
    self.swipeRemoveView.backgroundImageView.frame = CGRectMake(cell.frame.size.width, 0, 0, cell.frame.size.height);
    
    //Prevent cell selection
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // Add as a subview of tableView
    [self.tableView insertSubview:self.swipeRemoveView belowSubview:cell];
    self.swipeRemoveCell = cell;
    
    [UIView animateWithDuration:0.2 animations:^{
        CGFloat xOffset = cell.frame.size.width * 0.35 * (direction == UISwipeGestureRecognizerDirectionRight ? 1 : -1);
        // Animate cell over to reveal swipe view
        cell.frame = CGRectMake(xOffset, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height);
        
        // Animate inner shadow to follow cell
        self.swipeRemoveView.backgroundImageView.frame = CGRectMake(cell.frame.origin.x + cell.frame.size.width, self.swipeRemoveView.backgroundImageView.frame.origin.y, -xOffset, self.swipeRemoveView.backgroundImageView.frame.size.height);
    } completion:^(BOOL finished) {
        self.animatingSwipeView = NO;
    }];
}

- (void)hideSwipeRemoveView:(BOOL)animated 
{
    [self hideSwipeRemoveView:animated completion:nil];
}

- (void)hideSwipeRemoveView:(BOOL)animated completion:(RemoveAnimationCompletionBlock)completion 
{
    if (!self.swipeRemoveCell || self.animatingSwipeView) {
        return;
    }
    
    // Reset cell selection style
    self.swipeRemoveCell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    if (animated) {
        [UIView animateWithDuration:0.2 animations:^{
            // Animate cell back into position
            self.swipeRemoveCell.frame = CGRectMake(0, self.swipeRemoveCell.frame.origin.y, self.swipeRemoveCell.frame.size.width, self.swipeRemoveCell.frame.size.height);
            // Animate inner shadow to follow cell
            self.swipeRemoveView.backgroundImageView.frame = CGRectMake(self.swipeRemoveCell.frame.size.width, 0, 0, self.swipeRemoveCell.frame.size.height);
        } completion:^(BOOL finished) {
            self.animatingSwipeView = NO;
            self.swipeRemoveView.hidden = YES;
            [self.swipeRemoveView removeFromSuperview];
            self.swipeRemoveCell = nil;
            if (completion) {
                completion();
            }
        }];
    }
    else {
        // Move cell with no animation
        self.swipeRemoveCell.frame = CGRectMake(0, self.swipeRemoveCell.frame.origin.y, self.swipeRemoveCell.frame.size.width, self.swipeRemoveCell.frame.size.height);
        self.swipeRemoveView.hidden = YES;
        [self.swipeRemoveView removeFromSuperview];
        self.swipeRemoveCell = nil;
        if (completion) {
            completion();
        }
    }
    self.swipeRemoveViewVisible = NO;
}


@end
