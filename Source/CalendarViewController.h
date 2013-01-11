//
//  CalendarViewController.h
//  onething
//
//  Created by Dane Carr on 12-02-17.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "CreateGratitudeViewController.h"
#import "BaseViewController.h"

@interface CalendarViewController : BaseViewController

@property (nonatomic, strong) User *user;
@property (nonatomic, strong) NSCalendar *gregorianCalendar;
@property (nonatomic, strong) NSDateFormatter *interfaceDateFormatter;
@property (nonatomic, strong) NSDate *displayedMonth;
@property (nonatomic, strong) NSMutableArray *dayCells;
@property (nonatomic, strong) NSMutableArray *calendar;
@property (nonatomic, strong) NSMutableDictionary *calendarIndex;
@property (nonatomic, strong) NSOperation *updateOperation;
@property (nonatomic, strong) UIImageView *todayLabelBackground;
@property (nonatomic, weak) IBOutlet UILabel *monthLabel;
@property (nonatomic, weak) IBOutlet UIButton *previousMonthButton;
@property (nonatomic, weak) IBOutlet UIButton *nextMonthButton;
@property (nonatomic, weak) IBOutlet UIView *containerView;
@property (nonatomic, weak) IBOutlet UILabel *countLabel1;
@property (nonatomic, weak) IBOutlet UILabel *countLabel2;
@property (nonatomic, weak) IBOutlet UILabel *countLabel3;
@property (nonatomic, weak )IBOutlet UIView *labelContainerView;
@property (nonatomic, assign) BOOL animatingCalendar;
@property (nonatomic, assign) NSInteger currentMonthIndex;
@property (weak, nonatomic) IBOutlet UIButton *createGratitudeButton;

- (void)updateIndex;
- (void)drawCalendarForDate:(NSDate*)date;
- (IBAction)createGratitude:(id)sender;
- (IBAction)showNextMonth:(id)sender;
- (IBAction)showPreviousMonth:(id)sender;
- (void)updateCountLabels:(NSInteger)count;
- (void)swipe:(UISwipeGestureRecognizer*)recognizer direction:(UISwipeGestureRecognizerDirection)direction;
@end
