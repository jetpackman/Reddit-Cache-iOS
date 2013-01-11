//
//  BaseGratitudeTableView.m
//  onething
//
//  Created by Chris Taylor on 12-05-15.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import "BaseGratitudeTableView.h"

@implementation BaseGratitudeTableView

@synthesize circleGradientLayer = _circleLayer;
@synthesize growTransform = _growTransform;
@synthesize shrinkTransform = _shrinkTransform;
@synthesize showCircleAnimation = _showCircleAnimation;
@synthesize startTime = _startTime;
@synthesize endTime = _endTime;
@synthesize duration = _duration;
@synthesize user = _user;


- (void) awakeFromNib {
    [super awakeFromNib];
    [self initCircleLayer];
    self.showCircleAnimation = NO;
}

- (void) initCircleLayer {
    self.circleGradientLayer = [CAGradientLayer layer];
    
    // create the circle gradient
    CGMutablePathRef circlePath = CGPathCreateMutable();
    CGPathAddArc(circlePath, NULL, 0.f, 0.f, 20.f, 0.f, (float)2.f*M_PI, true);
    CGPathRelease(circlePath);
    self.circleGradientLayer.startPoint = (CGPoint){0.0,1.0};
    
    self.growTransform = CATransform3DMakeScale(50.f, 50.f, 1.f);
    self.shrinkTransform = CATransform3DMakeScale(0.005f, 0.005f, 1.f);
    
    self.circleGradientLayer.frame = (CGRect){-100,-100,50,50};
    self.circleGradientLayer.startPoint = (CGPoint){1.0, 0.0};
    self.circleGradientLayer.endPoint = (CGPoint){0.0, 1.0};
    
    UIColor* myYellow = [UIColor colorWithRed:(255.f/255.f) green:(255.f/255.f) blue:0.f alpha:0.7f];
    UIColor* myOrange = [UIColor colorWithRed:(255.f/255.f) green:(165.f/255.f) blue:0.f alpha:0.7f];

    self.circleGradientLayer.colors = [NSArray arrayWithObjects:(id)myYellow.CGColor, (id)myOrange.CGColor, nil];
    self.circleGradientLayer.cornerRadius = self.circleGradientLayer.frame.size.width/2;
    [self.layer addSublayer:self.circleGradientLayer];
}

- (void) hideCircle {
    // Begin hide animation
    [CATransaction setAnimationDuration:.5f];
    self.circleGradientLayer.transform = self.shrinkTransform;
    
    if (!self.showCircleAnimation && self.startTime) {
        self.endTime = [[NSDate date] timeIntervalSince1970];
        self.duration = self.endTime - self.startTime;
        NSLog(@"You held this for: %f long!", self.duration);
        NSLog(@"End: %f  || Start: %f", self.endTime, self.startTime);

        self.startTime = 0;
    }
    
    // Set it to NO just in case it already hasn't been
    self.showCircleAnimation = NO;
}

#pragma mark - Circle
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event  {
    [super touchesBegan:touches withEvent:event];
    
    if (self.showCircleAnimation) {
        // Move circle to animation start location
        [CATransaction setAnimationDuration:0];
        self.circleGradientLayer.position = [[touches anyObject] locationInView:self];
        self.circleGradientLayer.anchorPoint = CGPointMake(.5f, .5f);

        // Begin grow animation
        [CATransaction setAnimationDuration:10.f];
        self.circleGradientLayer.transform = self.growTransform;
        
        self.startTime = [[NSDate date] timeIntervalSince1970];
        
    }

}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    if(self.startTime) {
        [self hideCircle];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    if(self.startTime) {
        [self hideCircle];
    }
}

@end
