//
//  UIViewController+TWG.h
//  The Working Group
//
//  Created by Jeremy Bower on 11-11-06.
//  Copyright (c) 2011 The Working Group. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (TWG)

- (void)presentModalViewController:(UIViewController *)viewController
                        navigation:(BOOL)navigation
                          animated:(BOOL)animated;

@end
