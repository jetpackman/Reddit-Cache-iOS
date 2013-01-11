//
//  Gratitude.m
//  onething
//
//  Created by Dane Carr on 12-02-10.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import "Gratitude.h"

@implementation Gratitude

@synthesize gratitudeId = _gratitudeId;
@synthesize isMine = _isMine;
@synthesize isPublic = _isPublic;
@synthesize body = _body;
@synthesize createdAt = _createdAt;
@synthesize liked = _liked;
@synthesize likeCount = _likeCount;
@synthesize hasLocation = _hasLocation;
@synthesize location = _location;
@synthesize neighbourhood = _neighbourhood;
@synthesize city = _city;
@synthesize likedTime = _likedTime;


#pragma mark - Debug

- (NSString*) description
{
    return [NSString stringWithFormat:@"%@\n%@", [super description], [NSString stringWithFormat:@"\n ID: %@\n Body: %@\n createdAt:%@\n neighbourhood: %@\n city: %@\n ", self.gratitudeId, self.body, self.createdAt, self.neighbourhood, self.city]]; 
}
- (BOOL) hasLocation {
    return self.neighbourhood || self.city;
}

- (Gratitude*) copy {
    Gratitude* gratCopy = [[Gratitude alloc] init];
    gratCopy.gratitudeId = self.gratitudeId;
    gratCopy.isMine = self.isMine;
    gratCopy.body = self.body;
    gratCopy.createdAt = self.createdAt;
    gratCopy.liked = self.liked;
    gratCopy.likeCount = self.likeCount;
    gratCopy.hasLocation = self.hasLocation;
    gratCopy.location = self.location;
    gratCopy.neighbourhood = self.neighbourhood;
    gratCopy.city = self.city;
    gratCopy.likedTime = self.likedTime;
    return gratCopy;
}


@end
