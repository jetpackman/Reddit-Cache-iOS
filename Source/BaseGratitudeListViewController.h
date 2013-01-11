//
//  BaseGratitudeListViewController.h
//  onething
//
//  Created by Dane Carr on 12-02-13.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyGratitudeCell.h"
#import "User.h"
#import "CreateGratitudeViewController.h"
#import "TWGMenuController.h"
#import "SwipeEditView.h"
#import "PullToRefreshView.h"
#import "NetworkStatusView.h"
#import "BaseGratitudeTableView.h"
#import "ShareGratitudeCell.h"
#import "BaseViewController.h"
typedef void(^AnimationCompletionBlock)();

@interface BaseGratitudeListViewController : BaseViewController <UITableViewDelegate, UITableViewDataSource, TWGRootViewControllerProtocol, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate, PullToRefreshViewDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) Gratitude *editedGratitude;
@property (nonatomic, strong) NSMutableArray *gratitudes;
@property (nonatomic, strong) NSMutableArray *gratitudeListSections;
@property (nonatomic, strong) NSOperation *updateOperation;
@property (nonatomic, strong) User *user;
@property (nonatomic, assign) BOOL shareCellOpen;
@property (nonatomic, strong) NSIndexPath *shareCellIndexPath;
@property (nonatomic, weak) IBOutlet BaseGratitudeTableView *tableView;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) UIImageView *noGratitudesView;
@property (nonatomic, strong) NetworkStatusView *noNetworkView;
@property (nonatomic, strong) SwipeEditView *swipeEditView;
@property (nonatomic, strong) MyGratitudeCell *swipeEditCell;
@property (nonatomic, assign) BOOL swipeEditViewVisible;
@property (nonatomic, assign) BOOL animatingSwipeView;
@property (nonatomic, strong) NSDate *lastUpdatedAt;
@property (nonatomic, strong) PullToRefreshView *refreshView;
@property (nonatomic, assign) BOOL dragging;
@property (nonatomic, assign) BOOL gratitudeEditEnabled;
@property (nonatomic, assign) BOOL gratitudeShareDrawerEnabled;
@property (nonatomic, assign) BOOL onethingShareEnabled;
@property (nonatomic, assign) BOOL drawerSwipeEnabled;
@property (nonatomic, assign) BOOL isMyGratitudesList;
@property (nonatomic, assign) BOOL secondarySharingDrawerOpen;
@property (weak, nonatomic) IBOutlet UIButton *createGratitudeButton;


- (void)reloadGratitudes;
- (void)loadMoreGratitudes;
- (IBAction)createGratitude:(id)sender;
- (void)shareOnething:(id)sender;
- (void)shareEmail:(id)sender;
- (void)shareSms:(id)sender;
- (void)shareTwitter:(id)sender;
- (void)shareGratitudeOnFacebook;
- (void)openShareDrawerAtIndexPath:(NSIndexPath*)indexPath;
- (void)closeShareDrawer;
- (void)hideSwipeEditView:(BOOL)animated;
- (void)hideSwipeEditView:(BOOL)animated completion:(AnimationCompletionBlock)completion;
- (void)editGratitudeAtIndexPath:(NSIndexPath*)indexPath;
- (void)editButtonPressed:(id)sender;
- (void)createGestureRecognizers;
- (void)createSwipeView;
- (void)swipe:(UISwipeGestureRecognizer*)recognizer direction:(UISwipeGestureRecognizerDirection)direction;
- (void)showSwipeEditViewFor:(MyGratitudeCell*)cell direction:(UISwipeGestureRecognizerDirection)direction;


@end
