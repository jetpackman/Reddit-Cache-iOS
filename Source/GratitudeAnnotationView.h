//
//  GratitudeAnnotationView.h
//  onething
//
//  Created by Anthony Wong on 12-05-10.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface GratitudeAnnotationView : MKAnnotationView

@property (nonatomic, strong) UIImageView* imageView;
@property (nonatomic, strong) UILabel* countLabel;

@end
