//
//  OnboardingGratitudeCell.m
//  onething
//
//  Created by Anthony Wong on 2012-08-02.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import "OnboardingGratitudeCell.h"

@interface OnboardingGratitudeCell ()

@end

@implementation OnboardingGratitudeCell

@synthesize likeButton;

#define CELL_DEFAULT_HEIGHT 82.0f

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


+ (CGFloat)cellHeight
{
    return CELL_DEFAULT_HEIGHT;
}

- (void)likeButtonPressed:(id)sender
{
    // Post notification to the tableview
    NSLog(@"Like button pressed for onboarding cell!");
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"DismissOnboardingGratitudeCell" object:nil]];
    
}

- (void)configureCell
{
    [self setAccessibilityLabel:@"Connect to this gratitude by pressing the circle on the right"];
    [self.likeButton setAccessibilityLabel:@"Like button"];
    [self.likeButton addTarget:self action:@selector(likeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
}

@end
