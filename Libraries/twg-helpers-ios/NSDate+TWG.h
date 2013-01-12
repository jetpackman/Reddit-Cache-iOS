//
//  NSDate+NSDate_TWG.h
//  twg-ios-helpers
//
//  Created by Jeremy Bower on 12-01-27.
//  Copyright (c) 2012 The Working Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (TWG)

- (NSDate*)startOfDay;

- (BOOL)isBefore:(NSDate*)date;
- (BOOL)isAfter:(NSDate*)date;

@end
