//
//  TWGMarginLabel.m
//  Nitro
//
//  Created by Jeremy Bower on 12-02-08.
//  Copyright (c) 2012 Power Home Remodelling Group. All rights reserved.
//

#import "TWGMarginLabel.h"

@implementation TWGMarginLabel

@synthesize margins = _margins;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIEdgeInsets insets = {0, 0, 0, 0};
        self.margins = insets;
    }
    
    return self;
}

- (void)drawTextInRect:(CGRect)rect 
{
    return [super drawTextInRect:UIEdgeInsetsInsetRect(rect, self.margins)];
}

@end
