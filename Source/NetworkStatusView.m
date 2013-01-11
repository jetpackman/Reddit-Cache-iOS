//
//  NetworkStatusView.m
//  onething
//
//  Created by Dane Carr on 12-04-24.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import "NetworkStatusView.h"

@implementation NetworkStatusView

@synthesize retryButton = _retryButton;
@synthesize loadingIndicator = _loadingIndicator;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)showLoadingIndicator
{
    self.retryButton.hidden = YES;
    self.loadingIndicator.hidden = NO;
    [self.loadingIndicator startAnimating];
}

- (void)hideLoadingIndicator 
{
    [self.loadingIndicator stopAnimating];
    self.loadingIndicator.hidden = YES;
    self.retryButton.hidden = NO;
}

@end
