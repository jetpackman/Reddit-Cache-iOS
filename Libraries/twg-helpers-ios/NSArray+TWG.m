//
//  NSArray+TWG.m
//  The Working Group
//
//  Created by Jeremy Bower on 11-11-23.
//  Copyright (c) 2011 The Working Group. All rights reserved.
//

#import "NSArray+TWG.h"

@implementation NSArray (TWG)

- (id)firstObject
{
    return (self.count > 0 ? [self objectAtIndex:0] : nil);
}

- (NSArray*)arrayAfterFirstObject
{
    return (self.count > 0 ? 
            [self subarrayWithRange:NSMakeRange(1, self.count - 1)] : 
            [NSArray array]);
}

@end
