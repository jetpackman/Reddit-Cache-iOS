//
//  NSDateFormatter+TWG.m
//  Nitro
//
//  Created by Jeremy Bower on 12-02-07.
//  Copyright (c) 2012 Power Home Remodelling Group. All rights reserved.
//

#import "NSDateFormatter+TWG.h"

@implementation NSDateFormatter (TWG)

// Handles formats:
// RFC3339 (example: 2005-08-15T15:52:01+00:00)
// ISO-8601 (example: 2005-08-15T15:52:01+0000)
// ISO-8601 (example: 2005-08-15T15:52:01Z)
+ (NSDate*)dateFromString:(NSString*)str
{
    // Create a shared formatter.
    static NSDateFormatter* formatter = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    });
    
    NSMutableString *tempStr = [NSMutableString stringWithString:str];
    
    // Replace 'Zulu' time zone designator with UTC offset
    [tempStr replaceOccurrencesOfString:@"Z" withString:@"+0000" options:(NSBackwardsSearch | NSAnchoredSearch) range:NSMakeRange(0, tempStr.length)];
    
    // It's common for some Rails servers to include a colon in the date/time string.
    // Correct the timezone so iOS can parse it using the built-in timezone formatter.
    if (tempStr.length >= 23 && [tempStr characterAtIndex:22] == ':') {
        [tempStr deleteCharactersInRange:NSMakeRange(22, 1)];
    }

    str = tempStr;
    
    return [formatter dateFromString:str];
}

@end
