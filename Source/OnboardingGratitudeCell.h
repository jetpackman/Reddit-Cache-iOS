//
//  OnboardingGratitudeCell.h
//  onething
//
//  Created by Anthony Wong on 2012-08-02.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GratitudeLikeButton.h"

@interface OnboardingGratitudeCell : UITableViewCell
@property (weak, nonatomic) IBOutlet GratitudeLikeButton *likeButton;
+ (CGFloat)cellHeight;
- (void)configureCell;
@end
