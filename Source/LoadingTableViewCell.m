//
//  LoadingTableViewCell.m
//  onething
//
//  Created by Dane Carr on 12-02-21.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import "LoadingTableViewCell.h"

@implementation LoadingTableViewCell

@synthesize activityView = _activityView;

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self.activityView stopAnimating];
}

@end
