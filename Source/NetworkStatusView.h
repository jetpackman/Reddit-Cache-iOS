//
//  NetworkStatusView.h
//  onething
//
//  Created by Dane Carr on 12-04-24.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NetworkStatusView : UIView

@property (nonatomic, weak) IBOutlet UIButton *retryButton;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *loadingIndicator;

- (void)showLoadingIndicator;
- (void)hideLoadingIndicator;

@end
