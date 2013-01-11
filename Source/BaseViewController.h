//
//  BaseViewController.h
//  onething
//
//  Created by Anthony Wong on 12-05-22.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController

@property (nonatomic, strong) NSMutableArray* pushedViewControllers;
@property (nonatomic, assign) BOOL modalDisplayed;
@end

