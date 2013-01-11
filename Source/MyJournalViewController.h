//
//  MyJournalViewController.h
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
#import "BaseGratitudeListViewController.h"
@interface MyJournalViewController : BaseGratitudeListViewController

@property (nonatomic, strong) Gratitude *createdGratitude;
@property (nonatomic, assign) BOOL needsInjection;
@property (nonatomic, strong) IBOutlet UIImageView *bgImageView;
@property (nonatomic, strong) IBOutlet UIImageView *bgTapView;

- (void)gratitudeCreatedCallback:(Gratitude*)gratitude;

@end
