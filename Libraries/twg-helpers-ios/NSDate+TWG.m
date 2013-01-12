//
//  NSDate+NSDate_TWG.m
//  twg-ios-helpers
//
//  Created by Jeremy Bower on 12-01-27.
//  Copyright (c) 2012 The Working Group. All rights reserved.
//

#import "NSDate+TWG.h"

@implementation NSDate (TWG)

- (NSDate*)startOfDay
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    
    NSDateComponents *comps = [cal components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) 
                                     fromDate:self];
    return [cal dateFromComponents:comps];
}

- (BOOL)isBefore:(NSDate *)date
{
    return ([self compare:date] == NSOrderedAscending);
}

- (BOOL)isAfter:(NSDate *)date
{
    return ([self compare:date] == NSOrderedDescending);
}

@end
