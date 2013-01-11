//
//  MyGratitudeCell.h
//  onething
//
//  Created by Dane Carr on 12-02-14.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Gratitude.h"
#import "GratitudeLikeButton.h"
#import "TWGHighlightLabel.h"

@interface MyGratitudeCell : UITableViewCell

@property (nonatomic, strong) Gratitude *gratitude;
@property (nonatomic, weak) IBOutlet TWGHighlightLabel *bodyLabel;
@property (nonatomic, weak) IBOutlet UILabel *createdAtLabel;
@property (nonatomic, weak) IBOutlet GratitudeLikeButton *likeButton;

+ (CGFloat)heightForGratitude:(Gratitude*)gratitude;
+ (NSString*)formatDate:(NSDate*)date;

- (MyGratitudeCell*)configureWithGratitude:(Gratitude*)gratitude;
- (MyGratitudeCell*)configureWithGratitude:(Gratitude *)gratitude AndTopWord:(NSString*)topWord;

@end
