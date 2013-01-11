//
//  UIColor+Onething.m
//  onething
//
//  Created by Dane Carr on 12-04-12.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import "UIColor+Onething.h"

@implementation UIColor (Onething)

+ (UIColor*)tableSelectionColour {
    return [UIColor colorWithRed:1 green:1 blue:192.0/255.0 alpha:1];
}

+ (UIColor*)tableBackgroundColour {
    return [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_tile_light.png"]];
}

+ (UIColor*)tableTextColour {
    return [UIColor colorWithRed:34.0/255.0 green:57.0/255.0 blue:90.0/255.0 alpha:1.0];
}

+ (UIColor*)tableSeparatorColour {
    return [UIColor colorWithRed:171.0/255.0 green:171.0/255.0 blue:171.0/255.0 alpha:1.0];
}

@end
