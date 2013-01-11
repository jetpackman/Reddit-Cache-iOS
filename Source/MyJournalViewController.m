//
//  MyJournalViewController.m
//  onething
//
//  Created by Dane Carr on 12-02-13.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import "MyJournalViewController.h"
#import "LoadingTableViewCell.h"
#import "ShareGratitudeCell.h"
#import "TWGDropShadowView.h"
#import "OneThingAppDelegate.h"
#import "GratitudeMapViewController.h"

@implementation MyJournalViewController

@synthesize createdGratitude = _createdGratitude;
@synthesize needsInjection = _needsInjection;
@synthesize bgImageView = _bgImageView;
@synthesize bgTapView = _bgTapView;

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    [self configureNavBar];

    self.gratitudeEditEnabled = YES;
    self.gratitudeShareDrawerEnabled = YES;
    self.onethingShareEnabled = YES;
    
    [self.view setAccessibilityLabel:@"My Gratitude Screen"];
    [self.createdGratitude setAccessibilityLabel:@"Add Gratitude"];

}

-(void)configureNavBar
{
    [self setTitle:@"My Journal"];
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navbutton_map.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(showMyMap)];
    self.navigationItem.rightBarButtonItem = btn;
    [self.navigationItem.rightBarButtonItem setAccessibilityLabel:@"Map"];
}

- (void)showMyMap
{
    GratitudeMapViewController *gratitudeMapViewController = [[GratitudeMapViewController alloc] init];
    gratitudeMapViewController.user = self.user;
    gratitudeMapViewController.mine = YES; // Show only MY gratitudes
    
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle: @"Back" style: UIBarButtonItemStyleBordered target: nil action: nil];
    [[self navigationItem] setBackBarButtonItem: newBackButton];
    [self.navigationController pushViewController:gratitudeMapViewController animated:YES];
}

- (void)reloadGratitudes
{
    // Only one update operation at a time
    if (self.updateOperation) {
        return;
    }
    
    [[OnethingClientAPI sharedClient] gratitudesWithApiKey:self.user.apiKey 
                                                    perPage:GratitudesPerPage
                                                        startup:^(NSOperation *operation)
                                                        {
                                                            self.updateOperation = operation;
                                                            if (self.noNetworkView) {
                                                                [self.noNetworkView showLoadingIndicator];
                                                            }
                                                        } 
                                                        success:^(NSArray *gratitudes, int count)
                                                        {
                                                            // Network request was successful
                                                            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                                                
                                                                if (self.noNetworkView) {
                                                                    [UIView animateWithDuration:0.5 animations:^{
                                                                        self.noNetworkView.alpha = 0;
                                                                    } completion:^(BOOL finished) {
                                                                        self.noGratitudesView.hidden = YES;
                                                                        [self.view bringSubviewToFront:self.noGratitudesView];
                                                                        [self.noNetworkView removeFromSuperview];
                                                                        self.noNetworkView = nil;
                                                                    }];
                                                                }
                                                                if (self.tableView.tableHeaderView) {
                                                                    self.tableView.tableHeaderView = nil;
                                                                }
                                                                
                                                                // Show prompt when there are no gratitudes OR this is the first time user is opening the app
                                                                if (([gratitudes count] == 0 && [self.gratitudes count] == 0 && count == 0)) {
                                                                    self.noGratitudesView = [[UIImageView alloc] initWithFrame:self.tableView.frame];
                                                                    [self.noGratitudesView insertSubview:self.bgImageView aboveSubview:self.tableView];
                                                                    [self.noGratitudesView insertSubview:self.bgTapView aboveSubview:self.bgImageView];
                                                                    [self.view insertSubview:self.noGratitudesView aboveSubview:self.tableView];
                                                                }
                                                                else {
                                                                    if (self.noGratitudesView) {
                                                                        // Remove prompt
                                                                        self.noGratitudesView.hidden = YES;
                                                                        [self.view sendSubviewToBack:self.noGratitudesView];
                                                                        [self.view bringSubviewToFront:self.tableView];
                                                                        [self.view bringSubviewToFront:self.createGratitudeButton];
                                                                        [self.noGratitudesView removeFromSuperview];
                                                                        self.noGratitudesView = nil;
                                                                    }
                                                                    
                                                                    // Clear/allocate arrays
                                                                    self.gratitudes = [[NSMutableArray alloc] init];
                                                                    self.gratitudeListSections = [[NSMutableArray alloc] init];
                                                                    
                                                                    NSMutableArray *gratitudeSection = [[NSMutableArray alloc] init];
                                                                    NSMutableDictionary *gratitudeSectionDates = [[NSMutableDictionary alloc] init];
                                                                    
                                                                    // Create date for first section from first gratitude
                                                                    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:[[gratitudes objectAtIndex:0] createdAt]];
                                                                    components.hour = 0;
                                                                    components.minute = 0;
                                                                    [gratitudeSectionDates setObject:[[NSCalendar currentCalendar] dateFromComponents:components] forKey:@"absoluteDate"];
                                                                    for (Gratitude* gratitude in gratitudes) {
                                                                        if ([gratitude.createdAt timeIntervalSinceDate:[gratitudeSectionDates objectForKey:@"absoluteDate"]] > 0) {
                                                                            // Put gratitude in current section
                                                                            if([gratitude.gratitudeId intValue] != [self.createdGratitude.gratitudeId intValue]) {
                                                                                [gratitudeSection addObject:gratitude];
                                                                            } 
                                                                        }
                                                                        else {
                                                                            // Add completed section
                                                                            [self.gratitudes addObject:gratitudeSection];
                                                                            // Update date index
                                                                            [self.gratitudeListSections addObject:gratitudeSectionDates];
                                                                            // Create new section
                                                                            components = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:[gratitude createdAt]];
                                                                            gratitudeSectionDates = [NSMutableDictionary dictionaryWithObject:[[NSCalendar currentCalendar] dateFromComponents:components] forKey:@"absoluteDate"];
                                                                            gratitudeSection = [[NSMutableArray alloc] init];
                                                                            // Add gratitude to new section
                                                                            if([gratitude.gratitudeId intValue] != [self.createdGratitude.gratitudeId intValue]) {
                                                                                [gratitudeSection addObject:gratitude];
                                                                            }                                                                    
                                                                        }
                                                                    }
                                                                    
                                                                    if (gratitudeSection.count > 0) {
                                                                        // Add non-empty sections
                                                                        [self.gratitudes addObject:gratitudeSection];
                                                                        [self.gratitudeListSections addObject:gratitudeSectionDates];
                                                                    }
                                                                    // Update table
                                                                    [self.tableView reloadData];
                                                                    
                                                                    if (self.needsInjection) {
                                                                        [self injectGratitudeIntoTableView:self.createdGratitude];
                                                                        self.needsInjection = NO;
                                                                    }
                                                                }
                                                            }];
                                                        } 
                                                        failure:^(NSHTTPURLResponse *response, NSError *error)
                                                        {
                                                            NSLog(@"[ERROR] Failed to load gratitudes: %@ %@", [response debugDescription], [error userInfo]);
                                                            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                                                if ([self.gratitudes count] == 0) {
                                                                    if (!self.noNetworkView) {
                                                                        self.noNetworkView = (NetworkStatusView*)[[UIViewController alloc] initWithNibName:@"NetworkStatusView" bundle:nil].view;
                                                                        [self.noNetworkView.retryButton addTarget:self action:@selector(reloadGratitudes) forControlEvents:UIControlEventTouchUpInside];
                                                                        self.noNetworkView.alpha = 0;
                                                                        [self.view insertSubview:self.noNetworkView aboveSubview:self.tableView];
                                                                        [UIView animateWithDuration:0.5 animations:^{
                                                                            self.noNetworkView.alpha = 1;
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
                                                        completion:^
                                                        {
                                                            self.updateOperation = nil;
                                                            self.lastUpdatedAt = [NSDate date];
                                                            [self.refreshView finishedLoading];
                                                        }];
}

- (void)loadMoreGratitudes 
{
    // Only one update operation at a time
    if (self.updateOperation) {
        return;
    }    
    
    [[OnethingClientAPI sharedClient] gratitudesWithApiKey:self.user.apiKey 
                                                  anchorId:[((Gratitude*)[[self.gratitudes lastObject] lastObject]).gratitudeId intValue]
                                                   perPage:GratitudesPerPage
                                                   startup:^(NSOperation *operation) {
                                                       self.updateOperation = operation;
                                                   } 
                                                   success:^(NSArray *gratitudes, int count) {
                                                       if([gratitudes count] != 0) {
                                                           [[NSOperationQueue mainQueue] addOperationWithBlock:^{                                                           
                                                               // Show prompt when there are no gratitudes
                                                               if ([gratitudes count] == 0 && [self.gratitudes count] == 0) {
                                                                   self.noGratitudesView = [[UIImageView alloc] initWithFrame:self.tableView.frame];
                                                                   [self.noGratitudesView insertSubview:self.bgImageView aboveSubview:self.tableView];
                                                                   [self.noGratitudesView insertSubview:self.bgTapView aboveSubview:self.bgImageView];
                                                                   [self.view insertSubview:self.noGratitudesView aboveSubview:self.tableView];
                                                               } else {                                                                   
                                                                   // If the no gratitudesView is up
                                                                   if (self.noGratitudesView) {
                                                                       // Remove prompt
                                                                       self.noGratitudesView.hidden = YES;
                                                                       [self.view bringSubviewToFront:self.noGratitudesView];
                                                                       [self.noGratitudesView removeFromSuperview];
                                                                       self.noGratitudesView = nil;
                                                                   }
                                                                   
                                                                   
                                                                   NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:[[gratitudes objectAtIndex:0] createdAt]];
                                                                   components.hour = 0;
                                                                   components.minute = 0;
                                                                   
                                                                   // Table section headers
                                                                   NSMutableArray *gratitudeSection = nil;
                                                                   NSMutableDictionary *gratitudeSectionDates = nil;
                                                                   BOOL updateExistingSections;
                                                                   
                                                                   if (self.gratitudeListSections.count != 0 && self.gratitudes.count != 0) {
                                                                       gratitudeSection = [self.gratitudes lastObject];
                                                                       gratitudeSectionDates = [self.gratitudeListSections lastObject];
                                                                       updateExistingSections = YES;
                                                                   } else {
                                                                       gratitudeSection = [[NSMutableArray alloc] init];
                                                                       gratitudeSectionDates = [[NSMutableDictionary alloc] init];
                                                                       
                                                                       // Create date for first section from first gratitude
                                                                       [gratitudeSectionDates setObject:[[NSCalendar currentCalendar] dateFromComponents:components] forKey:@"absoluteDate"];
                                                                       updateExistingSections = NO;
                                                                   }
                                                                   
                                                                   for (Gratitude* gratitude in gratitudes) {
                                                                       // Check if gratitude is in the current section we are dealing with
                                                                       if ([gratitude.createdAt timeIntervalSinceDate:[gratitudeSectionDates objectForKey:@"absoluteDate"]] > 0) {
                                                                           // Put gratitude in current section
                                                                           [gratitudeSection addObject:gratitude];
                                                                       } else {
                                                                           // If we are NOT updating an existing section
                                                                           if (!updateExistingSections) {
                                                                               // Add completed section
                                                                               [self.gratitudes addObject:gratitudeSection];
                                                                               // Update date index
                                                                               [self.gratitudeListSections addObject:gratitudeSectionDates];
                                                                           } else {
                                                                               updateExistingSections = NO;
                                                                           }
                                                                           
                                                                           // Create new section
                                                                           components = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:[gratitude createdAt]];
                                                                           gratitudeSectionDates = [NSMutableDictionary dictionaryWithObject:[[NSCalendar currentCalendar] dateFromComponents:components] forKey:@"absoluteDate"];
                                                                           gratitudeSection = [[NSMutableArray alloc] init];
                                                                           
                                                                           // Add gratitude to new section
                                                                           [gratitudeSection addObject:gratitude];
                                                                       }
                                                                   }
                                                                   
                                                                   if (gratitudeSection.count > 0) {
                                                                       // Add non-empty sections
                                                                       [self.gratitudes addObject:gratitudeSection];
                                                                       [self.gratitudeListSections addObject:gratitudeSectionDates];
                                                                   }
                                                                   
                                                                   // Update table
                                                                   [self.tableView reloadData];
                                                               }
                                                           }];
                                                       }
                                                   } 
                                                   failure:^(NSHTTPURLResponse *response, NSError *error) {
                                                       NSLog(@"[ERROR] Failed to load gratitudes: %@ %@", [response debugDescription], [error userInfo]);
                                                   } 
                                                completion:^{
                                                    self.updateOperation = nil;
                                                }];
}

- (void) gratitudeCreatedCallback:(Gratitude*)gratitude
{
    self.createdGratitude = [gratitude copy];
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        if (!self.createdGratitude) {
            // nil gratitude means creation was cancelled
            self.modalDisplayed = NO;
            self.needsInjection = NO;
            [self dismissViewControllerAnimated:YES completion:nil];
            return;
        }
        
        if (self.noGratitudesView) {
            // Remove prompt if present
            self.noGratitudesView.hidden = YES;
            [self.view sendSubviewToBack:self.noGratitudesView];
            [self.view bringSubviewToFront:self.tableView];
            [self.view bringSubviewToFront:self.createGratitudeButton];
            [self.noGratitudesView removeFromSuperview];
            self.noGratitudesView = nil;
        }
        
        if (self.shareCellOpen) {
            [self closeShareDrawer];
        }
        if ([self.gratitudes count] != 0) {
            // Scroll tableView to top while still covered by modal
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }
        
        // Flag to signify the VC needs to inject the created gratitude;
        self.needsInjection = YES;
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (void) injectGratitudeIntoTableView:(Gratitude*)gratitude
{
    // Begin table view animations
    [self.tableView beginUpdates];
    
    // Update gratitude array
    if ([self.gratitudes count] == 0 || [gratitude.createdAt timeIntervalSinceDate:[[self.gratitudeListSections objectAtIndex:0] objectForKey:@"absoluteDate"]] < -86400) {
        // Table needs a new section
        [self.gratitudes insertObject:[NSMutableArray arrayWithObject:gratitude] atIndex:0];
        NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:gratitude.createdAt];
        NSMutableDictionary *sectionDate = [NSMutableDictionary dictionaryWithObject:[[NSCalendar currentCalendar] dateFromComponents:components] forKey:@"absoluteDate"];
        [self.gratitudeListSections insertObject:sectionDate atIndex:0];
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    }
    else {
        // Add gratitude to existing section
        [[self.gratitudes objectAtIndex:0] insertObject:gratitude atIndex:0];
    }
    
    // Update table
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    // End table animations
    [self.tableView endUpdates];
    
    // Scroll to gratitude
    [self.tableView scrollToRowAtIndexPath:0 atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
    [self openShareDrawerAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    self.createdGratitude = nil;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ([[self.gratitudeListSections objectAtIndex:section] objectForKey:@"dateString"]) {
        // Return date string for section if one has been stored
        return [[self.gratitudeListSections objectAtIndex:section] objectForKey:@"dateString"];
    }
    else {
        // Create, store, and return date string for section
        NSString *dateString = [self.dateFormatter stringFromDate:[[self.gratitudeListSections objectAtIndex:section] objectForKey:@"absoluteDate"]];
        [[self.gratitudeListSections objectAtIndex:section] setObject:dateString forKey:@"dateString"];
        return dateString;
    }
}

- (void)application:(UIApplication *)application willChangeStatusBarFrame:(CGRect)newStatusBarFrame {

    
}



@end