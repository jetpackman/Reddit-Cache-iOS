//
//  GratitudeBin.h
//  onething
//
//  Created by Anthony Wong on 12-05-10.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Gratitude.h"

typedef enum {
    MyGratitudeAnnotationType = 0,
    OthersGratitudeAnnotationType
} GratitudeAnnotationType;

@interface GratitudeBin : NSObject <MKAnnotation>
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) NSString *neighbourhood;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, assign) NSInteger gratCount;
@property (nonatomic, assign) BOOL mine;
@property (nonatomic, assign) GratitudeAnnotationType gratitudeType;
@property (nonatomic, assign) NSInteger publicGratCount;
@end
