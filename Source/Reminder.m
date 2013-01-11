//
//  Reminder.m
//  onething
//
//  Created by Dane Carr on 12-03-02.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import "Reminder.h"

@interface Reminder (private)

typedef enum {
    NoRepeat = 0,
    RepeatOnceWeekly = 1,
    RepeatWeekends = 2,
    RepeatWeekdays = 3,
    RepeatDaily = 4,
    RepeatCustom = 5
} RepeatType;

- (RepeatType)determineRepeatType;

@end

@implementation Reminder

@synthesize reminderID = _reminderID;
@synthesize version = _version;
@synthesize repeatTime = _repeatTime;
@synthesize repeatDays = _repeatDays;
@synthesize notificationSound = _notificationSound;

- (id)initWithDictionary:(NSDictionary *)dictionary 
{
    self = [super init];
    if (self) {
        // Initialize from dictionary
        self.version = [[dictionary objectForKey:@"version"] integerValue];
        if (self.version == 1) {
            self.reminderID = [dictionary objectForKey:@"reminderID"];
            
            self.repeatTime = [[NSDateComponents alloc] init];
            self.repeatTime.hour = [[dictionary objectForKey:@"hour"] integerValue];
            self.repeatTime.minute = [[dictionary objectForKey:@"minute"] integerValue];            
            self.repeatDays = [NSMutableArray arrayWithArray:[dictionary objectForKey:@"days"]];
            self.notificationSound = [dictionary objectForKey:@"notificationSound"];
        }
    }
    return self;
}

- (NSDictionary*)dictionaryRepresentation
{
    // Returns a dictionary for storage in NSUserDefaults
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithCapacity:5];
    
    [dictionary setObject:self.reminderID forKey:@"reminderID"];
    [dictionary setObject:[NSNumber numberWithInteger:self.version] forKey:@"version"];
    [dictionary setObject:[NSNumber numberWithInteger:self.repeatTime.hour] forKey:@"hour"];
    [dictionary setObject:[NSNumber numberWithInteger:self.repeatTime.minute] forKey:@"minute"];
    [dictionary setObject:[NSArray arrayWithArray:self.repeatDays] forKey:@"days"];
    if (self.notificationSound) {
        [dictionary setObject:self.notificationSound forKey:@"notificationSound"];
    }
    
    return dictionary;
}

- (RepeatType)determineRepeatType
{
    NSInteger repeatCount = 0;
    for (int i = 0; i < self.repeatDays.count; i++) {
        if ([[self.repeatDays objectAtIndex:i] boolValue]) {
            repeatCount++;
        }
    }
    if (repeatCount == 0) {
        return NoRepeat;
    }
    else if (repeatCount == 1) {
        return RepeatOnceWeekly;
    }
    else if (repeatCount == 2) {
        if ([[self.repeatDays objectAtIndex:0] boolValue] && [[self.repeatDays objectAtIndex:6] boolValue]) {
            return RepeatWeekends;
        }
    }
    else if (repeatCount == 5) {
        if (![[self.repeatDays objectAtIndex:0] boolValue] && ![[self.repeatDays objectAtIndex:6] boolValue]) {
            return RepeatWeekdays;
        }
    }
    else if (repeatCount == 7) {
        return RepeatDaily;
    }
    return RepeatCustom;
}

// Return human readable string of days reminder will repeat on
- (NSString*)daysAsString
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    RepeatType repeatType = [self determineRepeatType];
    
    if (repeatType == NoRepeat) {
        return @"Never";
    }
    else if (repeatType == RepeatOnceWeekly) {
        for (int i = 0; i < self.repeatDays.count; i++) {
            if ([[self.repeatDays objectAtIndex:i] boolValue]) {
                return [NSString stringWithFormat:@"Every %@", [[df weekdaySymbols] objectAtIndex:i]];
            }
        }
    }
    else if (repeatType == RepeatWeekends) {
        return @"Weekends";
    }
    else if (repeatType == RepeatWeekdays) {
        return @"Weekdays";
    }
    else if (repeatType == RepeatDaily) {
        return @"Every Day";
    }
    else {
        NSMutableString *daysString = [[NSMutableString alloc] init];
        for (int i = 0; i < self.repeatDays.count; i++) {
            if ([[self.repeatDays objectAtIndex:i] boolValue]) {
                if ([daysString isEqualToString:@""]) {
                    [daysString appendString:[[df shortWeekdaySymbols] objectAtIndex:i]];
                }
                else {
                    [daysString appendString:[NSString stringWithFormat:@", %@", [[df shortWeekdaySymbols] objectAtIndex:i]]];
                }
            }
        }
        return daysString;
    }
    return @"";
}

- (NSArray*)createLocalNotifications
{
    // Schedule notifications based on reminder parameters
    NSMutableArray *array = [[NSMutableArray alloc] init];
    RepeatType repeatType = [self determineRepeatType];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSString *alertBody = @"Reminder to record gratitude";
    NSString *alertAction = @"Record Gratitude";
    
    if (repeatType == RepeatCustom || repeatType == RepeatWeekends || repeatType == RepeatOnceWeekly) {
        for (int i = 0; i < self.repeatDays.count; i++) {
            if ([[self.repeatDays objectAtIndex:i] boolValue]) {
                NSDateComponents *dateComponents = [gregorian components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSWeekdayCalendarUnit) fromDate:[NSDate date]];
                dateComponents.hour = self.repeatTime.hour;
                dateComponents.minute = self.repeatTime.minute;
                
                NSDate *fireDate = [gregorian dateFromComponents:dateComponents];
                NSInteger repeatDay = i + 1;
                
                if (repeatDay > dateComponents.weekday) {
                    for (int j = 0; j < repeatDay - dateComponents.weekday; j++) {
                        fireDate = [fireDate dateByAddingTimeInterval:86400];
                    }
                }
                else if (repeatDay < dateComponents.weekday) {
                    for (int j = 0; j < 7 - (dateComponents.weekday - repeatDay); j++) {
                        fireDate = [fireDate dateByAddingTimeInterval:86400];
                    }
                }
                else {
                    // repeatDay == dateComponents.weekday
                    if ([fireDate timeIntervalSinceNow] < 0) {
                        // If fireDate is in the past, schedule notification 7 days later instead
                        fireDate = [fireDate dateByAddingTimeInterval:604800];
                    }
                }
                UILocalNotification *notification = [[UILocalNotification alloc] init];
                notification.timeZone = [NSTimeZone localTimeZone];
                notification.repeatCalendar = gregorian;
                notification.repeatInterval = NSWeekCalendarUnit;
                notification.fireDate = fireDate;
                notification.alertAction = alertAction;
                notification.alertBody = alertBody;
                notification.userInfo  = [NSMutableDictionary dictionaryWithObject:self.reminderID forKey:@"reminderId"];
                if (self.notificationSound) {
                    notification.soundName = self.notificationSound;
                }
                [array addObject:notification];
            }
        }
    }
    else {
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.timeZone = [NSTimeZone localTimeZone];
        notification.alertAction = alertAction;
        notification.alertBody = alertBody;
        notification.userInfo = [NSDictionary dictionaryWithObject:self.reminderID forKey:@"reminderId"];
        if (self.notificationSound) {
            notification.soundName = self.notificationSound;
        }
        
        NSDateComponents *dateComponents = [gregorian components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:[NSDate date]];
        dateComponents.hour = self.repeatTime.hour;
        dateComponents.minute = self.repeatTime.minute;
        
        NSDate *fireDate = [gregorian dateFromComponents:dateComponents];
        
        if (repeatType == NoRepeat || repeatType == RepeatDaily) {
            if ([fireDate timeIntervalSinceNow] < 0) {
                // If fireDate is in the past, schedule notification 24 hours later instead
                fireDate = [fireDate dateByAddingTimeInterval:86400];
            }
            
            notification.fireDate = fireDate;
            if (repeatType == RepeatDaily) {
                notification.repeatCalendar = gregorian;
                notification.repeatInterval = NSDayCalendarUnit;
            }
        }
        else if (repeatType == RepeatWeekdays) {
            if ([fireDate timeIntervalSinceNow] < 0) {
                // If fireDate is in the past, schedule notification 24 hours later instead
                fireDate = [fireDate dateByAddingTimeInterval:86400];
            }
            if ([gregorian components:NSWeekdayCalendarUnit fromDate:fireDate].weekday == 1) {
                // If fireDate is on Sunday, schedule notification for following Monday
                fireDate = [fireDate dateByAddingTimeInterval:86400];
            }
            else if ([gregorian components:NSWeekdayCalendarUnit fromDate:fireDate].weekday == 7) {
                // If fireDate is on Saturday, schedule notification for following Monday
                fireDate = [fireDate dateByAddingTimeInterval:172800];
            }
            
            notification.fireDate = fireDate;
            notification.repeatCalendar = gregorian;
            notification.repeatInterval = NSWeekdayCalendarUnit;
        }
        [array addObject:notification];
    }
    return [NSArray arrayWithArray:array];
}

@end
