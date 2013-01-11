//
//  Gratitude.h
//  onething
//
//  Created by Dane Carr on 12-02-10.
//  Copyright (c) 2012 1THING. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "MapKit/MapKit.h"

@interface Gratitude : NSObject

@property (nonatomic, strong) NSString* gratitudeId;
@property (nonatomic, assign) BOOL isMine;
@property (nonatomic, assign) BOOL isPublic;
@property (nonatomic, strong) NSString *body;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, assign) BOOL liked;
@property (nonatomic, assign) NSInteger likeCount;
@property (nonatomic, assign) BOOL hasLocation;
@property (nonatomic, assign) CLLocationCoordinate2D location;
@property (nonatomic, strong) NSString *neighbourhood;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSNumber *likedTime;

@end

