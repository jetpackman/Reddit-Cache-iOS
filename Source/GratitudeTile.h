//
//  GratitudeTile.h
//  onething
//
//  Created by Dane Carr on 12-02-21.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Gratitude.h"

@interface GratitudeTile : UIView

@property (nonatomic, strong) UILabel *bodyLabel;
@property (nonatomic, strong) UILabel *createdAtLabel;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

- (void)showLoadingIndicator;
- (void)hideLoadingIndicator;
- (void)setBody:(NSString*)body createdAt:(NSString*)createdAt;
- (void)resizeLabels;
@end
