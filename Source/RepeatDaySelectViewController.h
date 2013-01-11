//
//  RepeatDaySelectViewController.h
//  onething
//
//  Created by Dane Carr on 12-03-06.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^RepeatDaySelectCallbackBlock)(NSMutableArray *repeatDays);

@interface RepeatDaySelectViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *repeatDays;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, copy) RepeatDaySelectCallbackBlock callbackBlock;

@end
