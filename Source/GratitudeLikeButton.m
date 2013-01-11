//
//  GratitudeLikeButton.m
//  onething
//
//  Created by Anthony Wong on 12-05-15.
//  Copyright (c) 2012 1THING. All rights reserved.
//
#import "BaseGratitudeTableView.h"
#import "GratitudeLikeButton.h"

@implementation GratitudeLikeButton

- (void) hideCircleOverlay
{
    UIView* v = self;
    while(true) {
        v = v.superview;
        if([v isKindOfClass:[BaseGratitudeTableView class]]) {
            break;
        }
    }
    BaseGratitudeTableView *bv = (BaseGratitudeTableView*)v;
    bv.showCircleAnimation = NO;
    [bv hideCircle];
}

- (void) showCircleOverlay
{
    UIView* v = self;
    while(true) {
        v = v.superview;
        if([v isKindOfClass:[BaseGratitudeTableView class]]) {
            break;
        }
    }
    BaseGratitudeTableView *bv = (BaseGratitudeTableView*)v;
    bv.showCircleAnimation = YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(self.enabled) {
        [self showCircleOverlay];
        
    }
    [super touchesBegan:touches withEvent:event];
    [self.nextResponder touchesBegan:touches withEvent:event];
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(!self.highlighted)
    {
        [self hideCircleOverlay];

    }
    [super touchesMoved:touches withEvent:event];
    [self.nextResponder touchesMoved:touches withEvent:event];
}

-(void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event 
{
    [self hideCircleOverlay];

    [super touchesCancelled:touches withEvent:event];
    [self.nextResponder touchesCancelled:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self hideCircleOverlay];
    
    [super touchesEnded:touches withEvent:event];
    [self.nextResponder touchesEnded:touches withEvent:event];
}

@end

