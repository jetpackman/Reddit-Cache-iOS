//
//  GratitudeAnnotationView.m
//  onething
//
//  Created by Anthony Wong on 12-05-10.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import "GratitudeAnnotationView.h"
#import "GratitudeBin.h"
@implementation GratitudeAnnotationView

@synthesize imageView = _imageView;
@synthesize countLabel = _countLabel;


- (id) initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    GratitudeBin* myAnnotation = (GratitudeBin*)annotation;
    self = [super initWithAnnotation:myAnnotation reuseIdentifier:reuseIdentifier];
    self.frame = CGRectMake(0, 0, 23, 23);
    self.backgroundColor = [UIColor clearColor];

    if (myAnnotation.gratitudeType == MyGratitudeAnnotationType) {
        self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"button_map_my_gratitude.png"]];
    } else {
        self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"button_map_gratitude.png"]];
    }
    [self addSubview:self.imageView];
    
    [self.imageView setContentMode:UIViewContentModeScaleAspectFill];
    
    if (self.countLabel == nil){
        self.countLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, 1, 19, 21)];
        [self.countLabel setAdjustsFontSizeToFitWidth:YES];
        [self.countLabel setBackgroundColor:[UIColor clearColor]];
        [self.countLabel setFont:[UIFont systemFontOfSize:12.0f]];
        [self.countLabel setTextColor:[UIColor whiteColor]];
        [self.countLabel setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:self.countLabel];
    }
    
    
    [self setCanShowCallout:YES];
    [self setEnabled:YES];
    
    
    return self;
}
@end
