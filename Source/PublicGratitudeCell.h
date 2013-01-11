//
//  PublicGratitudeCell.h
//  onething
//
//  Created by Dane Carr on 12-04-17.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GratitudeLikeButton.h"

@interface PublicGratitudeCell : UITableViewCell

@property (nonatomic, strong) Gratitude *gratitude;
@property (nonatomic, weak) IBOutlet UILabel *bodyLabel;
@property (nonatomic, weak) IBOutlet UILabel *createdAtLabel;
@property (nonatomic, weak) IBOutlet UILabel *timePressedLabel;
@property (nonatomic, weak) IBOutlet GratitudeLikeButton *likeButton;

+ (CGFloat)heightForGratitude:(Gratitude*)gratitude;
+ (NSString*)formatDate:(NSDate*)date;
- (void)likeButtonPressed:(id)sender;

- (PublicGratitudeCell*)configureWithGratitude:(Gratitude*)gratitude;

@end
