//
//  NSMutableArray+TWG.m
//  twg-ios-helpers
//
//  Created by Jeremy Bower on 12-02-09.
//  Copyright (c) 2012 The Working Group. All rights reserved.
//

#import "NSMutableArray+TWG.h"

@implementation NSMutableArray (TWG)

- (id)removeFirstObject
{
    if (self.count == 0) {
        return nil;
    }
    
    id obj = [self objectAtIndex:0];
    [self removeObjectAtIndex:0];
    return obj;
}

@end
