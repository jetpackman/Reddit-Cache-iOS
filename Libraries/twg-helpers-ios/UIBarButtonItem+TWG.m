//
//  UIBarButtonItem+TWG.m
//  The Working Group
//
//  Created by Jeremy Bower on 11-11-06.
//  Copyright (c) 2011 The Working Group. All rights reserved.
//

#import "UIBarButtonItem+TWG.h"

@implementation UIBarButtonItem (TWG)

+ (UIBarButtonItem*)fixedSpace:(CGFloat)width
{
    UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace 
                                                                          target:nil 
                                                                          action:nil];
    item.width = width;
    return item;
}

+ (UIBarButtonItem*)flexibleSpace
{
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
}

@end
