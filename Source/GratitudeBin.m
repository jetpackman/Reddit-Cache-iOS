//
//  GratitudeBin.m
//  onething
//
//  Created by Anthony Wong on 12-05-10.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import "GratitudeBin.h"

@implementation GratitudeBin
@synthesize coordinate = _coordinate;
@synthesize neighbourhood = _neighbourhood;
@synthesize city = _city;
@synthesize gratCount = _gratCount;
@synthesize mine = _mine;
@synthesize gratitudeType = _gratitudeType;
@synthesize publicGratCount = _publicGratCount;



#pragma mark - MKAnnotation Protocol
- (NSString *)title
{
    if (self.mine) {
        
        if (self.gratCount > 1) {
            return @"Your Gratitudes";

        } else {
            return @"Your Gratitude";
        }
    } else {
        if (self.gratCount > 1) {
            return @"Others' Gratitudes";
            
        } else {
            return @"Other's Gratitude";
        }
    }
}

- (NSString *)subtitle 
{
    return nil;
}

@end
