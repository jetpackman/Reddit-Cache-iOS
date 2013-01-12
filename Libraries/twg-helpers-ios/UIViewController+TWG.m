//
//  UIViewController+TWG.m
//  The Working Group
//
//  Created by Jeremy Bower on 11-11-06.
//  Copyright (c) 2011 The Working Group. All rights reserved.
//

#import "UIViewController+TWG.h"

@implementation UIViewController (TWG)

- (void)presentModalViewController:(UIViewController *)viewController
                        navigation:(BOOL)navigation
                          animated:(BOOL)animated
{
    UIViewController* viewControllerToPresent = viewController;
    if (navigation) {
        viewControllerToPresent = [[UINavigationController alloc] initWithRootViewController:viewController];
    }
    
    [self presentModalViewController:viewControllerToPresent navigation:NO animated:YES];

}

@end
