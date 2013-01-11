//
//  BaseGratitudeListViewController.m
//  onething
//
//  Created by Dane Carr on 12-02-13.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import "BaseGratitudeListViewController.h"
#import "LoadingTableViewCell.h"
#import "ShareGratitudeCell.h"
#import "OnboardingGratitudeCell.h"
#import "TWGDropShadowView.h"
#import "MyJournalViewController.h"
#import "PublicGratitudeCell.h"
#import "OneThingAppDelegate.h"
#import "MBProgressHUD.h"
#import "NSObject+TWG.h"

@implementation BaseGratitudeListViewController

@synthesize gratitudes = _gratitudes;
@synthesize gratitudeListSections = _gratitudeListSections;
@synthesize editedGratitude = _editedGratitude;
@synthesize updateOperation = _updateOperation;
@synthesize user = _user;
@synthesize shareCellOpen = _shareCellOpen;
@synthesize shareCellIndexPath = _shareCellIndexPath;
@synthesize tableView = _tableView;
@synthesize dateFormatter = _dateFormatter;
@synthesize noGratitudesView = _noGratitudesView;
@synthesize noNetworkView = _noNetworkView;
@synthesize swipeEditView = _swipeEditView;
@synthesize swipeEditCell = _swipeEditCell;
@synthesize swipeEditViewVisible = _swipeEditViewVisible;
@synthesize animatingSwipeView = _animatingSwipeView;
@synthesize lastUpdatedAt = _lastUpdatedAt;
@synthesize refreshView = _refreshView;
@synthesize dragging = _dragging;
@synthesize gratitudeEditEnabled = _gratitudeEditEnabled;
@synthesize gratitudeShareDrawerEnabled = _gratitudeShareDrawerEnabled;
@synthesize onethingShareEnabled = _onethingShareEnabled;
@synthesize drawerSwipeEnabled = _drawerSwipeEnabled;
@synthesize isMyGratitudesList = _isMyGratitudesList;
@synthesize secondarySharingDrawerOpen = _secondarySharingDrawerOpen;
@synthesize createGratitudeButton = _createGratitudeButton;

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initialize use-variables
    self.shareCellOpen = NO;
    self.swipeEditViewVisible = NO;
    
    // Default configuration settings
    self.gratitudeEditEnabled = NO;
    self.gratitudeShareDrawerEnabled = NO;
    self.onethingShareEnabled = NO;
    self.drawerSwipeEnabled = YES;
    self.isMyGratitudesList = YES;
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateStyle:NSDateFormatterLongStyle];
    
    [self.tableView setBackgroundColor:[UIColor tableBackgroundColour]];
    self.tableView.user = self.user;
    
    // Setup the drag to reload functionality
    self.refreshView = [[PullToRefreshView alloc] initWithScrollView:self.tableView];
    self.refreshView.delegate = self;
    self.refreshView.backgroundColor = [UIColor clearColor];
    [self.tableView addSubview:self.refreshView];
    
    [self createSwipeView];
    [self createGestureRecognizers];
    
    // Clear/allocate arrays
    self.gratitudes = [[NSMutableArray alloc] init];
    self.gratitudeListSections = [[NSMutableArray alloc] init];
    
    
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadGratitudes];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // Return cells to normal state when view disappears
    if (self.shareCellOpen) {
        [self closeShareDrawer];
    }
    if (self.swipeEditViewVisible) {
        [self hideSwipeEditView:YES];
    }
}

- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self setCreateGratitudeButton:nil];
    [super viewDidUnload];
    
    [self.refreshView containingViewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)createSwipeView {
    // Create view containing edit button
    UIViewController *vc = [[UIViewController alloc] initWithNibName:@"SwipeEditView" bundle:nil];
    self.swipeEditView = (SwipeEditView*) vc.view;
    [self.swipeEditView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_tile.png"]]];
    [self.swipeEditView.editButton addTarget:self action:@selector(editButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.swipeEditView.editButton setBackgroundImage:[[UIImage imageNamed:@"button_edit.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 5, 14, 5)] forState:UIControlStateNormal];
    
    [self.swipeEditView.backgroundImageView setImage:[[UIImage imageNamed:@"bg_inside_shadow.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(4, 4, 4, 4)]];
    [self.swipeEditView.backgroundImageView setAlpha:0.75];
}

#pragma  mark - Gestures

- (void)createGestureRecognizers  {
    UISwipeGestureRecognizer *rightSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)];
    rightSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:rightSwipeGestureRecognizer];
    
    UISwipeGestureRecognizer *leftSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)];
    leftSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:leftSwipeGestureRecognizer];
    
    UISwipeGestureRecognizer *buttonSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(createGratitudeSwiped:)];
    buttonSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
    [self.createGratitudeButton addGestureRecognizer:buttonSwipeGestureRecognizer];
}

- (void)createGratitudeSwiped:(UISwipeGestureRecognizer*)reconigzer
{
    [self createGratitude:reconigzer];
}

- (void)swipeLeft:(UISwipeGestureRecognizer*)recognizer {
    [self swipe:recognizer direction:UISwipeGestureRecognizerDirectionLeft];
}

- (void)swipeRight:(UISwipeGestureRecognizer*)recognizer {
    [self swipe:recognizer direction:UISwipeGestureRecognizerDirectionRight];
}

- (void)swipe:(UISwipeGestureRecognizer*)recognizer direction:(UISwipeGestureRecognizerDirection)direction {
    if (recognizer && recognizer.state == UIGestureRecognizerStateEnded) {
        if (self.shareCellOpen) {
            [self closeShareDrawer];
        }
        if (self.swipeEditViewVisible) {
            // Swiping when a cell has already been swiped hides the swipe view
            [self hideSwipeEditView:YES];
            return;
        }
        
        if (direction == UISwipeGestureRecognizerDirectionRight && self.drawerSwipeEnabled) {
            // Show drawer menu for right swipe
            [(TWGMenuController*)self.parentViewController.parentViewController showLeftDrawer];
            return;
        }
        
        if(self.gratitudes && self.gratitudeEditEnabled && direction == UISwipeGestureRecognizerDirectionLeft) {
            // Find cell that was swiped on
            CGPoint location = [recognizer locationInView:self.tableView];
            NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
            MyGratitudeCell *cell = (MyGratitudeCell*)[self.tableView cellForRowAtIndexPath:indexPath];
            [self showSwipeEditViewFor:cell direction:direction];
        }
    }

    // Dismiss the circle overlay for some reason if you have it up.
    if(self.tableView.startTime) {
        [self.tableView hideCircle];
    }
}

- (void)showSwipeEditViewFor:(MyGratitudeCell*)cell direction:(UISwipeGestureRecognizerDirection)direction {
    self.swipeEditViewVisible = YES;
    
    // Move swipeEditView to below cell
    self.swipeEditView.frame = cell.frame;
    self.swipeEditView.hidden = NO;
    
    // Position drop shadow
    self.swipeEditView.backgroundImageView.frame = CGRectMake(cell.frame.size.width, 0, 0, cell.frame.size.height);
    
    //Prevent cell selection
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // Add as a subview of tableView
    [self.tableView insertSubview:self.swipeEditView belowSubview:cell];
    self.swipeEditCell = cell;
    
    [UIView animateWithDuration:0.2 animations:^{
        CGFloat xOffset = cell.frame.size.width * 0.35 * (direction == UISwipeGestureRecognizerDirectionRight ? 1 : -1);
        // Animate cell over to reveal swipe view
        cell.frame = CGRectMake(xOffset, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height);
        
        // Animate inner shadow to follow cell
        self.swipeEditView.backgroundImageView.frame = CGRectMake(cell.frame.origin.x + cell.frame.size.width, self.swipeEditView.backgroundImageView.frame.origin.y, -xOffset, self.swipeEditView.backgroundImageView.frame.size.height);
    } completion:^(BOOL finished) {
        self.animatingSwipeView = NO;
    }];
}

- (void)hideSwipeEditView:(BOOL)animated {
    [self hideSwipeEditView:animated completion:nil];
}

- (void)hideSwipeEditView:(BOOL)animated completion:(AnimationCompletionBlock)completion {
    if (!self.swipeEditCell || self.animatingSwipeView) {
        self.swipeEditViewVisible = NO;
        return;
    }
    
    // Reset cell selection style
    self.swipeEditCell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    if (animated) {
        [UIView animateWithDuration:0.2 animations:^{
            // Animate cell back into position
            self.swipeEditCell.frame = CGRectMake(0, self.swipeEditCell.frame.origin.y, self.swipeEditCell.frame.size.width, self.swipeEditCell.frame.size.height);
            // Animate inner shadow to follow cell
            self.swipeEditView.backgroundImageView.frame = CGRectMake(self.swipeEditCell.frame.size.width, 0, 0, self.swipeEditCell.frame.size.height);
        } completion:^(BOOL finished) {
            self.animatingSwipeView = NO;
            self.swipeEditView.hidden = YES;
            [self.swipeEditView removeFromSuperview];
            self.swipeEditCell = nil;
            if (completion) {
                completion();
            }
        }];
    }
    else {
        // Move cell with no animation
        self.swipeEditCell.frame = CGRectMake(0, self.swipeEditCell.frame.origin.y, self.swipeEditCell.frame.size.width, self.swipeEditCell.frame.size.height);
        self.swipeEditView.hidden = YES;
        [self.swipeEditView removeFromSuperview];
        self.swipeEditCell = nil;
        if (completion) {
            completion();
        }
    }
    self.swipeEditViewVisible = NO;
}

#pragma mark - Gratitudes

- (void)reloadGratitudes {
    NSAssert(NO, @"This is an abstract method and should be overridden.");
}

- (void)loadMoreGratitudes {
    NSAssert(NO, @"This is an abstract method and should be overridden.");
}

- (IBAction)createGratitude:(id)sender {
    // Sync defaults so user doesn't see it again!
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    if (![defaults boolForKey:@"hasSeenCreateTooltip"]) {
        [defaults setBool:TRUE forKey:@"hasSeenCreateTooltip"];
        [defaults synchronize];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CreatingGratitudeNotification object:nil];
}

- (void)editGratitudeAtIndexPath:(NSIndexPath *)indexPath {
    // Editing of gratitudes can only be done in screens where your own gratitudes are being shown. As such editing a gratitude will leave you on that screen
    // Initialize view controller
    CreateGratitudeViewController *viewController = [[CreateGratitudeViewController alloc] init];
    viewController.user = self.user;
    viewController.editGratitude = [[[self.gratitudes objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] copy];
    self.editedGratitude = [viewController.editGratitude copy];
    viewController.canceledGratitudeCallback = ^ {
        [self dismissViewControllerAnimated:YES completion:^ {
            [self.tableView reloadData];
            self.editedGratitude = nil;
        }];
    };
    viewController.createGratitudeCallback = ^(Gratitude *gratitude) {
        // Close edit view
        if (self.swipeEditViewVisible) {
            [self hideSwipeEditView:NO];
        }
        // Update gratitude
        [[self.gratitudes objectAtIndex:indexPath.section] replaceObjectAtIndex:indexPath.row withObject:gratitude];
        [self dismissViewControllerAnimated:YES completion:^ {
            self.editedGratitude = nil;
            // Animate table changes
            [self.tableView beginUpdates];
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
            [self.tableView endUpdates];
            [self.tableView reloadData];
        }];
    };
    
    [viewController setModalPresentationStyle:UIModalTransitionStyleCoverVertical];
    [self presentViewController:viewController animated:YES completion:nil];

    
}

#pragma mark - Actions

- (void)editButtonPressed:(id)sender {
    if (self.swipeEditViewVisible) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:self.swipeEditCell];
        [self editGratitudeAtIndexPath:indexPath];
    }
}

- (void)shareOnething:(id)sender {    
    // Gratitude can only be made public once
    [(UIButton*)sender setEnabled:NO];
    
    // Get index path for shared gratitude
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(self.shareCellIndexPath.row - 1) inSection:self.shareCellIndexPath.section];
    Gratitude *gratitude = [[self.gratitudes objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    [[OnethingClientAPI sharedClient] publishGratitude:gratitude 
                                              apiKey:self.user.apiKey 
                                             startup:nil
                                             success:^(Gratitude* resultGratitude) {
                                                 // Fade in cell layout changes
                                                 [self.tableView beginUpdates];
                                                 gratitude.isPublic = YES;
                                                 [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                                                 [self.tableView endUpdates];
                                                 // Select cell in case it was deselected during reload
                                                 [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
                                             }failure:^(NSHTTPURLResponse *response, NSError *error) {
                                                 NSLog(@"[ERROR] Failed to share gratitude: %@ %@", [response debugDescription], [error userInfo]);
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
                                             } completion:nil];
}

#pragma mark - Email/SMS

- (void)shareEmail:(id)sender  {
    // Get gratitude to be shared
    Gratitude *gratitude = [[self.gratitudes objectAtIndex:self.shareCellIndexPath.section] objectAtIndex:self.shareCellIndexPath.row - 1];
    
    // Create mail composer vc
    MFMailComposeViewController *viewController = [[MFMailComposeViewController alloc] init];
    viewController.mailComposeDelegate = self;

    // Format the mail composer with HTML
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"email_template" ofType:@"html"];
    if (filePath) {
        NSString* htmlAsString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        htmlAsString = [htmlAsString stringByReplacingOccurrencesOfString:@"%body%" withString:gratitude.body];
        htmlAsString = [htmlAsString stringByReplacingOccurrencesOfString:@"%user%" withString:self.user.name];

        [viewController setMessageBody:htmlAsString isHTML:YES];
        [self presentViewController:viewController animated:YES completion:nil];

    }
    

}

// MFMailComposeViewController delegate method
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)shareSms:(id)sender {
    
    if ([MFMessageComposeViewController canSendText]) {
        // Get gratitude to be shared
        Gratitude *gratitude = [[self.gratitudes objectAtIndex:self.shareCellIndexPath.section] objectAtIndex:self.shareCellIndexPath.row - 1];
        
        // Create SMS composer vc
        MFMessageComposeViewController *viewController = [[MFMessageComposeViewController alloc] init];    
        
        // Set message body
        viewController.body = [NSString stringWithFormat:@"I'm grateful for... %@", gratitude.body];
        viewController.messageComposeDelegate = self;
        [self presentViewController:viewController animated:YES completion:nil];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No SMS!" message:@"This device cannot send SMS" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        
    }

}

// MFMessageComposeViewController delegate method
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Twitter

- (void)shareTwitter:(id)sender {
    // Get gratitude to be shared
    Gratitude *gratitude = [[self.gratitudes objectAtIndex:self.shareCellIndexPath.section] objectAtIndex:self.shareCellIndexPath.row - 1];       
    
    [[OnethingClientAPI sharedClient] shareGratitude:gratitude 
                                              apiKey:self.user.apiKey 
                                             startup:nil
                                             success:^(Gratitude* resultGratitude) {
                                                 // Create the template.
                                                 NSString* templateString = (gratitude.isPublic ?
                                                                             @"Someone is grateful for \"%@\" via @1THINGapp" :
                                                                             @"I am grateful for \"%@\" via @1THINGapp");
                                                 NSUInteger templateLen = templateString.length - @"%@".length;
                                                 
                                                 // Create the message.
                                                 NSUInteger maxBodyLen = 140 - templateLen;
                                                 NSString* messageString = nil;
                                                 if (gratitude.body.length > maxBodyLen) {
                                                     NSString* elipses = @"...";
                                                     NSString* truncatedBody = [gratitude.body substringToIndex:(maxBodyLen - elipses.length)];
                                                     truncatedBody = [NSString stringWithFormat:@"%@%@", truncatedBody, elipses];
                                                     messageString = [NSString stringWithFormat:templateString, truncatedBody];
                                                 }
                                                 else {
                                                     messageString = [NSString stringWithFormat:templateString, gratitude.body];
                                                 }
                                                 
                                                 
                                                 // Setup the Twitter composer.
                                                 SLComposeViewController *viewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
                                                 [viewController setInitialText:messageString];
                                                 viewController.completionHandler = ^(SLComposeViewControllerResult result) {
                                                     [self dismissViewControllerAnimated:YES completion:nil];
                                                 };
                                                 
                                                 // Show the Twitter composer.
                                                 [self presentViewController:viewController animated:YES completion:nil];
                                             } failure:^(NSHTTPURLResponse *response, NSError *error) {
                                                 NSLog(@"[ERROR] Failed to share gratitude: %@ %@", [response debugDescription], [error userInfo]);
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
                                             } completion:nil];
}

#pragma mark - Facebook

- (void) shareFacebook:(id)sender {

    [self shareGratitudeOnFacebook];
}


- (void) shareGratitudeOnFacebook {
    // Get gratitude to be shared
    Gratitude *gratitude = [[self.gratitudes objectAtIndex:self.shareCellIndexPath.section] objectAtIndex:self.shareCellIndexPath.row - 1];       
    
    [[OnethingClientAPI sharedClient] shareGratitude:gratitude 
                                                apiKey:self.user.apiKey 
                                               startup:nil
                                               success:^(Gratitude* resultGratitude) {
                                                   // Create the template.
                                                   NSString* templateString = (gratitude.isPublic ?
                                                                               @"Someone is grateful for \"%@\" via @1THINGapp" :
                                                                               @"I am grateful for \"%@\" via @1THINGapp");
                                                  NSString* messageString = [NSString stringWithFormat:templateString, gratitude.body];
                                                   NSURL *url = [NSURL URLWithString:@"http://1thingapp.com/"];
                                                                                                      
                                                   SLComposeViewController *viewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
                                                   [viewController setInitialText: messageString];
                                                   [viewController addURL:url];
                                                   [self presentViewController:viewController animated:YES completion:^() {
                                                       [self closeSecondaryShareDrawer];
                                                   }];
                                                                           
                                                   // Extend the drawer
                                                   [self openSecondaryShareDrawerWithText:@"Sharing on Facebook"];
                                               }failure:^(NSHTTPURLResponse *response, NSError *error) {
                                                   NSLog(@"[ERROR] Failed to share gratitude: %@ %@", [response debugDescription], [error userInfo]);
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
                                               } completion:nil];
}

#pragma mark - Table

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (!self.gratitudes) {
        // Section for loading cell
        return 1;
    }
    return self.gratitudes.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!self.gratitudes) {
        // Row for loading cell
        return 1;
    }
    return [[self.gratitudes objectAtIndex:section] count];
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    // Create custom view for header    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [self tableView:tableView heightForHeaderInSection:section])];
    headerView.backgroundColor = [UIColor colorWithRed:34.0/255.0 green:57.0/255.0 blue:90.0/255.0 alpha:0.8];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 3, headerView.frame.size.width - 18, headerView.frame.size.height - 6)];
    
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.opaque = NO;
    headerLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    headerLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    headerLabel.textColor = [UIColor whiteColor];
    
    [headerView addSubview:headerLabel];
    
    return headerView;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
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
        
            [cell setAccessibilityLabel:@"Share Gratitude Cell"];
            return cell;
        } else {
            // Dequeue a gratitude cell
            if (self.isMyGratitudesList) {
                MyGratitudeCell *cell = nil;
                
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
                Gratitude* gratitude = [[self.gratitudes objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];

                //Accessibility
                [cell setAccessibilityLabel: cell.textLabel.text];
                
                // Tell cell to configure itself
                if([gratitude.gratitudeId intValue] != [self.editedGratitude.gratitudeId intValue]) {
                    cell = [cell configureWithGratitude:gratitude];
                } else {
                    cell = [cell configureWithGratitude:self.editedGratitude];
                }
                return cell;
            } else {
                Gratitude* gratitude = [[self.gratitudes objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
          

                if ([gratitude.gratitudeId isEqualToString:@"ONBOARDING"] && ![[NSUserDefaults standardUserDefaults] objectForKey:@"hasSeenShareTooltip"]) {
                    OnboardingGratitudeCell *cell;
                    UIViewController* viewController = [[UIViewController alloc] initWithNibName:@"OnboardingGratitudeCell" bundle:nil];
                    cell = (OnboardingGratitudeCell*) viewController.view;
                    UIView *backgroundView = [[UIView alloc] init];
                    [backgroundView setBackgroundColor:[UIColor tableBackgroundColour]];
                    cell.backgroundView = backgroundView;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    
                    [cell configureCell];
                    
                    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissOnboardingGratitudeCell:) name:@"DismissOnboardingGratitudeCell" object:nil];
                    return cell;
                } else {
                    PublicGratitudeCell *cell = [self.tableView dequeueReusableCellWithIdentifier:PublicGratitudeCellIdentifier];
                    if (!cell) {
                        // Create new gratitude cell
                        UIViewController* viewController = [[UIViewController alloc] initWithNibName:@"PublicGratitudeCell" bundle:nil];
                        cell = (PublicGratitudeCell*) viewController.view;
                        UIView *backgroundView = [[UIView alloc] init];
                        [backgroundView setBackgroundColor:[UIColor tableBackgroundColour]];
                        cell.backgroundView = backgroundView;
                        
                        UIImageView *selectedBackgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"bg_gratitude_cell_select.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(4, 4, 4, 4)]];
                        selectedBackgroundView.frame = CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height);
                        cell.selectedBackgroundView = selectedBackgroundView;
                        
                    }
                    // Tell cell to configure itself
                    cell = [cell configureWithGratitude:[[self.gratitudes objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];
                    
                    if (cell.gratitude.isMine) {
                        cell.likeButton.enabled = NO;
                        [cell.likeButton removeTarget:cell action:@selector(likeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
                        [cell.likeButton setTitle:@"" forState:UIControlStateDisabled];
                        switch (cell.gratitude.likeCount) {
                            case 0:
                                [cell.likeButton setBackgroundImage:[UIImage imageNamed:@"fingerprint_blue.png"] forState:UIControlStateDisabled];
                                break;
                            case 1:
                                [cell.likeButton setBackgroundImage:[UIImage imageNamed:@"fingerprint_blue_1.png"] forState:UIControlStateDisabled];
                                break;
                            case 2:
                                [cell.likeButton setBackgroundImage:[UIImage imageNamed:@"fingerprint_blue_2.png"] forState:UIControlStateDisabled];
                                break;
                            case 3:
                                [cell.likeButton setBackgroundImage:[UIImage imageNamed:@"fingerprint_blue_3.png"] forState:UIControlStateDisabled];
                                break;
                            case 4:
                                [cell.likeButton setBackgroundImage:[UIImage imageNamed:@"fingerprint_blue_4.png"] forState:UIControlStateDisabled];
                                break;
                            case 5:
                                [cell.likeButton setBackgroundImage:[UIImage imageNamed:@"fingerprint_blue_5.png"] forState:UIControlStateDisabled];
                                break;
                            default:
                                [cell.likeButton setBackgroundImage:[UIImage imageNamed:@"fingerprint_blue_6.png"] forState:UIControlStateDisabled];
                                [cell.likeButton setTitle:[NSString stringWithFormat:@"%d", cell.gratitude.likeCount] forState:UIControlStateDisabled];
                                break;
                        }
                    }
                    return cell;
                }
               
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
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.gratitudes) {
        // Loading cell height
        return 64.0f;
    }
    else if (self.shareCellOpen && indexPath.row == self.shareCellIndexPath.row && indexPath.section == self.shareCellIndexPath.section) {
        // Share cell height
        return self.secondarySharingDrawerOpen ? 80.f : 50.f;
    }
    else {
        // Calculate cell height based on gratitude
        Gratitude *gratitude = [[self.gratitudes objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        if(self.isMyGratitudesList) {
            if([gratitude.gratitudeId intValue] != [self.editedGratitude.gratitudeId intValue]) {
                return [MyGratitudeCell heightForGratitude:gratitude];
            } else {
                return [MyGratitudeCell heightForGratitude:self.editedGratitude];
            }
        } else {
            if ([gratitude.gratitudeId isEqualToString:@"ONBOARDING"]) {
                return [OnboardingGratitudeCell cellHeight];
            } else {
                return [PublicGratitudeCell heightForGratitude:gratitude];

            }
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.gratitudes) {
        return 28.0f;
    }
    // No section headers for loading cell
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Gratitude *gratitude = [[self.gratitudes objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    // Hide edit view before showing share cell
    if (self.swipeEditViewVisible) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        [self hideSwipeEditView:YES];
        return;
    }
    if (self.gratitudeShareDrawerEnabled && ![[gratitude gratitudeId] isEqualToString:@"ONBOARDING"]) {
        [self openShareDrawerAtIndexPath:indexPath];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    // Close edit view and share cells before scrolling
    if (self.shareCellOpen) {
        [self closeShareDrawer];
    }
    if (self.swipeEditViewVisible) {
        [self hideSwipeEditView:YES];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // Load more gratitudes when table scrolls close to the bottom
    float yPosition = scrollView.contentOffset.y + scrollView.bounds.size.height - scrollView.contentInset.bottom;
    float reloadDistance = 20.0f;
    
    if (yPosition > scrollView.contentSize.height + reloadDistance && !self.dragging) {
        self.dragging = true;
        
        if (!self.shareCellOpen) {
            [self loadMoreGratitudes];
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    self.dragging = false;
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    // Close edit view and share cells before scrolling
    if (self.swipeEditViewVisible) {
        [self hideSwipeEditView:YES];
    }
    if (self.shareCellOpen) {
        [self closeShareDrawer];
    }
    // Allow scrolling to top
    return YES;
}

- (void)openShareDrawerAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.gratitudes) {
        return;
    }
    if (self.shareCellOpen) {
        if (self.shareCellIndexPath.row == indexPath.row && self.shareCellIndexPath.section == indexPath.section) {
            // If share cell was tapped, do nothing
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section] animated:NO scrollPosition:UITableViewScrollPositionNone];
            return;
        }
        // Deselect row
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
        // Close share drawer
        [self closeShareDrawer];
        
        return;
    }
    
    // Ensure cell shows selected background
    [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    
    self.shareCellOpen = YES;   
    self.shareCellIndexPath = [NSIndexPath indexPathForRow:(indexPath.row + 1) inSection:indexPath.section];
    
    // Animate in share cell
    [self.tableView beginUpdates];
    [[self.gratitudes objectAtIndex:indexPath.section] insertObject:[[Gratitude alloc] init] atIndex:self.shareCellIndexPath.row];
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:self.shareCellIndexPath] withRowAnimation:UITableViewRowAnimationTop];
    [self.tableView endUpdates];
    
    // Ensure share cell is visible
    [self.tableView scrollToRowAtIndexPath:self.shareCellIndexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
}

- (void) openSecondaryShareDrawerWithText:(NSString*)text {
    // Expand the secondary drawer
    self.secondarySharingDrawerOpen = YES;
    ShareGratitudeCell* cell = (ShareGratitudeCell*) [self.tableView cellForRowAtIndexPath:self.shareCellIndexPath];
    [cell.sharingActivitySpinner setHidden:NO];
    [cell.sharingActivitySpinner startAnimating];
    [cell.sharingLabel setHidden:NO];
    [cell.sharingLabel setText:text];
    [cell.sharingImage setHidden:YES];
    [cell recenterSpinnerAndLabel];
    // Update table
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}


- (void) updateSecondaryShareDrawerWithSuccess:(BOOL)success andText:(NSString*)text {
    if (self.secondarySharingDrawerOpen) {
        // Update the secondary drawer text
        ShareGratitudeCell* cell = (ShareGratitudeCell*) [self.tableView cellForRowAtIndexPath:self.shareCellIndexPath];
        [cell.sharingLabel setText:text];
        [cell.sharingActivitySpinner setHidden:YES];
        if(success){
            [cell.sharingImage setHidden:NO];
        }
        [cell recenterImageAndLabel];
        
        // Set Accessibility Label for Testing purposes
        [cell setAccessibilityLabel: cell.textLabel.text];
        
        // Only show the result message for 1 sec before dismissing the extended portion of the drawer
        [self performSelector:@selector(closeSecondaryShareDrawer) withObject:nil afterDelay:1.0];
    }
    
}

- (void) closeSecondaryShareDrawer {
    if (self.secondarySharingDrawerOpen) {
        self.secondarySharingDrawerOpen = NO;
        // Update table
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
        
        ShareGratitudeCell* cell = (ShareGratitudeCell*) [self.tableView cellForRowAtIndexPath:self.shareCellIndexPath];
        
        // Animate hiding of the drawer and then hide the label/spinner/image of extended drawer
        [self performAfterDelay:0.2 onQueue:[NSOperationQueue mainQueue] block: ^(void){
            [cell.sharingActivitySpinner setHidden:YES];
            [cell.sharingLabel setHidden:YES];
            [cell.sharingImage setHidden:YES];
        }];
        
    }
}

- (void)closeShareDrawer {
    self.shareCellOpen = NO;
    self.secondarySharingDrawerOpen = NO;
    
    [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:(self.shareCellIndexPath.row - 1) inSection:self.shareCellIndexPath.section] animated:YES];
    if (self.shareCellIndexPath.row < [[self.gratitudes objectAtIndex:self.shareCellIndexPath.section] count]) {
        [[self.gratitudes objectAtIndex:self.shareCellIndexPath.section] removeObjectAtIndex:self.shareCellIndexPath.row];
    }
    
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:self.shareCellIndexPath] withRowAnimation:UITableViewRowAnimationTop];
    [self.tableView endUpdates];
}

- (void)pullToRefreshViewShouldRefresh:(PullToRefreshView *)view {
    [self reloadGratitudes];
}

- (NSDate*)pullToRefreshViewLastUpdated:(PullToRefreshView *)view {
    return self.lastUpdatedAt;
}


@end