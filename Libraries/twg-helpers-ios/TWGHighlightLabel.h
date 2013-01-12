//
//  TWGAttributedLabel.h
//  The Working Group
//
//  Created by Chris Taylor on 12-05-16.
//  Copyright (c) 2012 The Working Group Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>


@interface TWGHighlightLabel : UILabel

@property (nonatomic, strong) UIColor* highlightColor;              // The color of the highlight
@property (nonatomic, strong) UIColor* highlightForegroundColor;    // The color of the text that is highlighted
@property (nonatomic, strong) NSString* key;                        // The string you are looking to highlight

@end