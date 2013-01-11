//
//  GratitudesForDateViewController.h
//  onething
//
//  Created by Dane Carr on 12-03-28.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyGratitudeCell.h"
#import "User.h"
#import "TWGMenuController.h"
#import "SwipeEditView.h"
#import "PullToRefreshView.h"
#import "NetworkStatusView.h"
#import "BaseGratitudeListViewController.h"

@interface GratitudesForDateViewController : BaseGratitudeListViewController


@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end
