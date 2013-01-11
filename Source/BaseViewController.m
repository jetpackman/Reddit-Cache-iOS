//
//  BaseViewController.m
//  onething
//
//  Created by Anthony Wong on 12-05-22.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import "BaseViewController.h"
@implementation BaseViewController
@synthesize pushedViewControllers = _pushedViewControllers;
@synthesize modalDisplayed = _modalDisplayed;

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.modalDisplayed = NO;
}

@end
