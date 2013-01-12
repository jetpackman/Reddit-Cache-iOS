//
//  TWGAttributedLabel.m
//  The Working Group
//
//  Created by Chris Taylor on 12-05-16.
//  Copyright (c) 2012 The Working Group Inc. All rights reserved.
//

#import "TWGHighlightLabel.h"
#import "NSMutableAttributedString+TWG.h"

// ------ Anonymous Category
@interface TWGHighlightLabel ()

// Private properties
@property (nonatomic, assign) BOOL keyInstancesFound;
@property (nonatomic, strong) NSArray* keyInstanceLocations;
@property (nonatomic, assign) CTFrameRef textFrame;
@property (nonatomic, strong) NSMutableAttributedString* attributedString;

@end

// ------ Implementation
@implementation TWGHighlightLabel

// Privates
@synthesize keyInstancesFound = _keyInstancesFound;
@synthesize keyInstanceLocations = _keyInstanceLocations;
@synthesize textFrame = _textFrame;
@synthesize attributedString = _attributedString;

// Publics
@synthesize highlightColor = _highlightColor;
@synthesize highlightForegroundColor = _highlightForegroundColor;
@synthesize key = _key;

#pragma mark - Helpers

- (void)findInstancesOfString:(NSString*)key
{
    if (!self.keyInstancesFound) {
        NSError *error = NULL;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"\\b%@\\b", key ]
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:&error];
        NSString* string = self.text; // Entire label
        NSRange range = NSMakeRange(0, string.length);
        
        self.keyInstanceLocations = [regex matchesInString:string options:0 range:range];
        self.keyInstancesFound = YES;
    }
}

- (NSMutableAttributedString *)mutableAttributedStringWithHighlighting
{
    NSMutableAttributedString* attributedString = [self.attributedString mutableCopy];
    
    // For each key instance found, we mark the range of that key instance with the ForegroundColorAttribute.
    for (NSTextCheckingResult* result in self.keyInstanceLocations) {
        [attributedString removeAttribute:(NSString *)kCTForegroundColorAttributeName range:result.range];
        [attributedString addAttribute:(NSString*)kCTForegroundColorAttributeName
                                 value:(id)self.highlightForegroundColor.CGColor
                                 range:result.range];
    }
    
    return attributedString;
}

#pragma mark - Overrides
- (void)drawTextInRect:(CGRect)rect {
    
    if (!self.highlightForegroundColor) {
        // If the highlight foreground color has not been set, then we use the text color of the label
        self.highlightForegroundColor = self.textColor;
    }
    
    if (!self.highlightColor) {
        // If the highlight color has not been set, default to the 1THING yellow
        self.highlightColor = [UIColor colorWithRed:(255.f/255.f) green:(255.f/255.f) blue:(192.f/255.f) alpha:1];
    }
    
    // Configure our attributed string
    self.keyInstancesFound = NO;
    self.attributedString = [[NSMutableAttributedString alloc] initWithString:self.text];
    [self.attributedString setFont:self.font]; // Uses UILabel font
    [self.attributedString setTextColor:self.textColor]; // Uses UILabel textcolor
    
    // Figure out the places to highlight
    [self findInstancesOfString:self.key];
    
    // If there are things to highlight
    if ([self.keyInstanceLocations count]) {
        CGContextRef ctx = UIGraphicsGetCurrentContext();
		CGContextSaveGState(ctx);
        
        // Flip the bounds of context as CoreText and UIKit use opposite context bounds
        CGContextConcatCTM(ctx, CGAffineTransformScale(CGAffineTransformMakeTranslation(0, self.bounds.size.height),
                                                       1.f, -1.f));
        // Construct the attributed string that has highlighting
        NSMutableAttributedString* attributedStringWithHighlighting = [self mutableAttributedStringWithHighlighting];
        
        CFAttributedStringRef attributedString = (__bridge CFAttributedStringRef)attributedStringWithHighlighting;
        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(attributedString);
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, self.bounds);
        self.textFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
        CGPathRelease(path);
        CFRelease(framesetter);
        
        [self.highlightColor setFill];
        
        CFArrayRef lines = CTFrameGetLines(self.textFrame);
        CFIndex count = CFArrayGetCount(lines);
        CGPoint lineOrigins[count];
        CTFrameGetLineOrigins(self.textFrame, CFRangeMake(0, 0), lineOrigins);
        
        // For each line, check if a key instance occurs and if it does construct and draw a corresponding highlighted frame
        for (CFIndex i = 0; i < count; i++) {
            // Set the fill color of the highlighting
            CTLineRef line = CFArrayGetValueAtIndex(lines, i);
            
            CGRect highlightRect = CGRectZero;
            CFArrayRef runs = CTLineGetGlyphRuns(line);
            CFIndex runCount = CFArrayGetCount(runs);
            
            // For each instance of a key on a line, construct the highlight rectangle for the portion of the instance on the line
            for (CFIndex k = 0; k < runCount; k++) {
                
                // For each marked section of the attributed string, construct and draw a highlighted region for the key instances
                for(NSTextCheckingResult* instance in self.keyInstanceLocations) {
                    
                    CTRunRef run = CFArrayGetValueAtIndex(runs, k);
                    
                    CFRange stringRunRange = CTRunGetStringRange(run);
                    NSRange lineRunRange = NSMakeRange(stringRunRange.location, stringRunRange.length);
                    NSRange intersectedRunRange = NSIntersectionRange(lineRunRange, instance.range);
                    if (intersectedRunRange.length == 0) {
                        continue;
                    }
                    
                    CGFloat ascent = 0.0f;
                    CGFloat descent = 0.0f;
                    CGFloat leading = 0.0f;
                    
                    //Figures out the number of characters before the location to offset
                    CFIndex lineOffset =  CTLineGetStringRange(CFArrayGetValueAtIndex(lines, i)).location;
                    
                    CGFloat width = (CGFloat)CTRunGetTypographicBounds(run,
                                                                       CFRangeMake(instance.range.location - lineOffset,instance.range.length),
                                                                       &ascent,
                                                                       &descent,
                                                                       &leading);
                    
                    CGFloat height = ascent + descent;
                    CGFloat xOffset = CTLineGetOffsetForStringIndex(line,
                                                                    instance.range.location,
                                                                    nil);
                    
                    
                    CGRect instanceRect = CGRectMake(lineOrigins[i].x + xOffset - leading,
                                                     lineOrigins[i].y - descent,
                                                     width + leading,
                                                     height);
                    
                    instanceRect = CGRectIntegral(instanceRect);
                    instanceRect = CGRectInset(instanceRect, -2, -1);
                    
                    if (CGRectIsEmpty(highlightRect)) {
                        highlightRect = instanceRect;
                    } else {
                        highlightRect = CGRectUnion(highlightRect, instanceRect);
                    }
                }
                
                // Draw the highlight rectangle
                if (!CGRectIsEmpty(highlightRect)) {
                    CGContextMoveToPoint(ctx, highlightRect.origin.x, highlightRect.origin.y);
                    CGContextAddLineToPoint(ctx, highlightRect.origin.x + highlightRect.size.width, highlightRect.origin.y);
                    CGContextAddLineToPoint(ctx, highlightRect.origin.x + highlightRect.size.width, highlightRect.origin.y + highlightRect.size.height);
                    CGContextAddLineToPoint(ctx, highlightRect.origin.x, highlightRect.origin.y + highlightRect.size.height);
                    CGContextAddLineToPoint(ctx, highlightRect.origin.x, highlightRect.origin.y);
                    CGContextFillPath(ctx);
                }
            }
        }
        
        // Draw the text
        CTFrameDraw(self.textFrame, ctx);
        CGContextRestoreGState(ctx);
        
    } else {
        // Draw the text by calling super
        [super drawTextInRect:rect];
    }
}


@end