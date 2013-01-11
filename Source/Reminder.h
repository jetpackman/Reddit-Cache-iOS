//
//  Reminder.h
//  onething
//
//  Created by Dane Carr on 12-03-02.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Reminder : NSObject

@property (nonatomic, strong) NSString *reminderID;
@property (nonatomic, assign) NSInteger version;
@property (nonatomic, strong) NSDateComponents *repeatTime;
@property (nonatomic, strong) NSMutableArray *repeatDays;
@property (nonatomic, strong) NSString *notificationSound;

- (NSString*)daysAsString;
- (id)initWithDictionary:(NSDictionary*)dictionary;
- (NSDictionary*)dictionaryRepresentation;
- (NSArray*)createLocalNotifications;

@end
