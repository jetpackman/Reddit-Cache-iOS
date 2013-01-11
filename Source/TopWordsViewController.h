//
//  TopWordsViewController.h
//  onething
//
//  Created by Anthony Wong on 12-05-09.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "NetworkStatusView.h"
#import "TWGMenuController.h"
#import "PullToRefreshView.h"
#import "CreateGratitudeViewController.h"
#import "TopWordsCell.h"
#import "SwipeEditView.h"
#import "BaseViewController.h"
typedef void(^RemoveAnimationCompletionBlock)();

@interface TopWordsViewController : BaseViewController <UITableViewDelegate, UITableViewDataSource, TWGRootViewControllerProtocol, PullToRefreshViewDelegate>
@property (nonatomic, strong) UIImageView *noGratitudesView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) User* user;
@property (nonatomic, strong) NSOperation* updateOperation;
@property (nonatomic, strong) NetworkStatusView* noNetworkView;
@property (nonatomic, strong) NSMutableArray* topWords;
@property (nonatomic, strong) PullToRefreshView* refreshView;
@property (nonatomic, strong) NSDate *lastUpdated;
@property (nonatomic, strong) SwipeEditView *swipeRemoveView;
@property (nonatomic, strong) TopWordsCell *swipeRemoveCell;
@property (nonatomic, assign) BOOL animatingSwipeView;
@property (nonatomic, assign) BOOL swipeRemoveViewVisible;
@property (weak, nonatomic) IBOutlet UIButton *createGratitudeButton;

- (IBAction)createGratitude:(id)sender;
- (void)hideSwipeRemoveView:(BOOL)animated;
- (void)hideSwipeRemoveView:(BOOL)animated completion:(RemoveAnimationCompletionBlock)completion;
- (void)removeButtonPressed:(id)sender;
- (void)createGestureRecognizers;
- (void)swipe:(UISwipeGestureRecognizer*)recognizer direction:(UISwipeGestureRecognizerDirection)direction;
- (void)showSwipeRemoveViewFor:(TopWordsCell*)cell direction:(UISwipeGestureRecognizerDirection)direction;
- (void)reloadTopWords;

@end
