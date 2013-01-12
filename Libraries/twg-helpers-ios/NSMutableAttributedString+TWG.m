//
//  NSMutableAttributedString+TWG.m
//  onething
//
//  Created by Chris Taylor on 12-05-16.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import "NSMutableAttributedString+TWG.h"
#import <CoreText/CoreText.h>


@implementation NSMutableAttributedString (TWG)

- (void) setTextColor:(UIColor*)color range:(NSRange)range {
    [self removeAttribute:(NSString *)kCTForegroundColorAttributeName range:range];
	[self addAttribute:(NSString*)kCTForegroundColorAttributeName
                 value:(id)color.CGColor
                 range:range];
}

- (void) setTextColor:(UIColor*)color {
    [self setTextColor:color range:NSMakeRange(0, [self length])];
}

- (void) setFont:(UIFont*)font range:(NSRange)range {
    CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize, nil);
    [self removeAttribute:(NSString*)kCTFontAttributeName range:range];
	[self addAttribute:(NSString*)kCTFontAttributeName value:(__bridge id)fontRef range:range];
	CFRelease(fontRef);
}

- (void) setFont:(UIFont*)font {
    [self setFont:font range:NSMakeRange(0, [self length])];
}
@end
