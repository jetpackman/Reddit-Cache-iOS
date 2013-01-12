//
//  NSMutableAttributedString+TWG.h
//  onething
//
//  Created by Chris Taylor on 12-05-16.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableAttributedString (TWG) 

- (void) setTextColor:(UIColor*)color range:(NSRange)range;
- (void) setTextColor:(UIColor*)color;
- (void) setFont:(UIFont*)font range:(NSRange)range;
- (void) setFont:(UIFont*)font;
@end
