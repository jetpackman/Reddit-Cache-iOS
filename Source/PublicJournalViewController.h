//
//  SharedGratitudeViewController.h
//  onething
//
//  Created by Dane Carr on 12-03-30.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "TWGMenuController.h"
#import "PullToRefreshView.h"
#import "CreateGratitudeViewController.h"
#import "NetworkStatusView.h"
#import "BaseGratitudeListViewController.h"

@interface PublicJournalViewController : BaseGratitudeListViewController
@property (nonatomic, strong) IBOutlet UIImageView *bgImageView;
@property (nonatomic, strong) IBOutlet UIImageView *bgTapView;

@property (nonatomic, assign) NSInteger count;

@end
