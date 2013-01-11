//
//  BaseGratitudeTableView.h
//  onething
//
//  Created by Chris Taylor on 12-05-15.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseGratitudeTableView : UITableView

@property (nonatomic, strong) CAGradientLayer* circleGradientLayer;
@property (nonatomic, assign) CATransform3D growTransform;
@property (nonatomic, assign) CATransform3D shrinkTransform;
@property (nonatomic, assign) BOOL showCircleAnimation;
@property (nonatomic, assign) NSTimeInterval startTime;
@property (nonatomic, assign) NSTimeInterval endTime;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, strong) User* user;


- (void) initCircleLayer;
- (void) hideCircle;
@end
