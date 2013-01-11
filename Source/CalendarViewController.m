//
//  CalendarViewController.m
//  onething
//
//  Created by Dane Carr on 12-02-17.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import "CalendarViewController.h"
#import "GratitudesForDateViewController.h"

@implementation CalendarViewController

@synthesize user = _user;
@synthesize gregorianCalendar = _gregorianCalendar;
@synthesize interfaceDateFormatter = _interfaceDateFormatter;
@synthesize displayedMonth = _displayedMonth;
@synthesize dayCells = _dayCells;
@synthesize calendar = _calendar;
@synthesize calendarIndex = _calendarIndex;
@synthesize updateOperation = _updateOperation;
@synthesize todayLabelBackground = _todayLabelBackground;
@synthesize monthLabel = _monthLabel;
@synthesize nextMonthButton = _nextMonthButton;
@synthesize previousMonthButton = _previousMonthButton;
@synthesize containerView = _containerView;
@synthesize countLabel1 = _countLabel1;
@synthesize countLabel2 = _countLabel2;
@synthesize countLabel3 = _countLabel3;
@synthesize labelContainerView = _labelContainerView;
@synthesize animatingCalendar = _animatingCalendar;
@synthesize currentMonthIndex = _currentMonthIndex;
@synthesize createGratitudeButton = _createGratitudeButton;

#define CONTAINER_VERTICAL_MARGIN 4.0f
#define CONTAINER_HORIZONTAL_MARGIN 1.0f

#define SLIDE_ANIMATION_DURATION 0.3f

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"Calendar"];
    [self updateCountLabels:0];

    self.pushedViewControllers = [NSMutableArray array];
    
    [self.view setAccessibilityLabel:@"Calendar Screen"];

    self.currentMonthIndex = 0;
    self.animatingCalendar = NO;
    self.todayLabelBackground = nil;
    [self.view setBackgroundColor:[UIColor tableBackgroundColour]];
    
    self.containerView.layer.borderWidth = 1.0f;
    self.containerView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.containerView.layer.cornerRadius = 3.0f;
    
    self.nextMonthButton.hidden = YES;
    self.gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    self.interfaceDateFormatter = [[NSDateFormatter alloc] init];
    [self.interfaceDateFormatter setDateStyle:NSDateFormatterLongStyle];
    self.dayCells = [[NSMutableArray alloc] init];
    self.calendar = [[NSMutableArray alloc] init];
    self.calendarIndex = [[NSMutableDictionary alloc] init];
    self.displayedMonth = [NSDate date];
    
    // Create swipe gesture recognizers
    UISwipeGestureRecognizer *rightSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)];
    rightSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:rightSwipeGestureRecognizer];
    UISwipeGestureRecognizer *leftSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)];
    leftSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:leftSwipeGestureRecognizer];
    UISwipeGestureRecognizer *buttonSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(createGratitudeSwiped:)];
    buttonSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
    [self.createGratitudeButton addGestureRecognizer:buttonSwipeGestureRecognizer];
    
        
    // Get list of days with gratitudes
    NSDateComponents *dateComponents = [self.gregorianCalendar components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:[NSDate date]];
    [dateComponents setMonth:dateComponents.month - 6];
    if (dateComponents.month < 1) {
        [dateComponents setMonth:dateComponents.month + 12];
        [dateComponents setYear:dateComponents.year - 1];
    }
    NSDate *fromDate = [self.gregorianCalendar dateFromComponents:dateComponents];
    dateComponents = [self.gregorianCalendar components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:[NSDate date]];
    NSTimeInterval secondsPerDay = 24 * 60 * 60;
    NSDate *toDate = [[NSDate date] dateByAddingTimeInterval: secondsPerDay];
    [[OnethingClientAPI sharedClient] calendarIndexWithApiKey:self.user.apiKey 
                                                     fromDate:fromDate  
                                                       toDate:toDate
                                                      startup:^(NSOperation *operation){
                                                          self.updateOperation = operation;
                                                      } 
                                                      success:^(NSArray *calendarIndex) {
                                                          [self.calendar addObjectsFromArray:calendarIndex];
                                                      } 
                                                      failure:^(NSHTTPURLResponse *response, NSError *error) {
                                                          NSLog(@"[ERROR] Failed to load calendar data: %@ %@", [response debugDescription], [error userInfo]);
                                                      } 
                                                   completion:^{
                                                       self.updateOperation = nil;
                                                       [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                                           [self drawCalendarForDate:[NSDate date]];
                                                       }];
                                                   }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.pushedViewControllers removeAllObjects];
}

- (void)updateIndex 
{
    if (self.updateOperation) {
        return;
    }
    
    NSDateComponents *dateComponents = [self.gregorianCalendar components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:self.displayedMonth];
    [dateComponents setMonth:dateComponents.month - 6];
    if (dateComponents.month < 1) {
        [dateComponents setMonth:dateComponents.month + 12];
        [dateComponents setYear:dateComponents.year - 1];
    }
    NSDate *fromDate = [self.gregorianCalendar dateFromComponents:dateComponents];
    NSDate *toDate = self.displayedMonth;

    [[OnethingClientAPI sharedClient] calendarIndexWithApiKey:self.user.apiKey 
                                                     fromDate:fromDate 
                                                       toDate:toDate startup:^(NSOperation *operation) {
                                                           self.updateOperation = operation;
                                                       } success:^(NSArray *calendarIndex) {
                                                           [self.calendar addObjectsFromArray:calendarIndex];
                                                       } failure:^(NSHTTPURLResponse *response, NSError *error) {
                                                           NSLog(@"[ERROR] Failed to load calendar data: %@ %@", [response debugDescription], [error userInfo]);
                                                       } completion:^{
                                                           self.updateOperation = nil;
                                                           [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                                               [self drawCalendarForDate:self.displayedMonth];
                                                           }];
                                                       }];
}

- (void)createGratitudeSwiped:(UISwipeGestureRecognizer*)recognizer {
    [self createGratitude:recognizer];
}

- (void)swipeRight:(UISwipeGestureRecognizer*)recognizer 
{
    [self swipe:recognizer direction:UISwipeGestureRecognizerDirectionRight];
}

- (void)swipeLeft:(UISwipeGestureRecognizer*)recognizer
{
    [self swipe:recognizer direction:UISwipeGestureRecognizerDirectionLeft];
}

- (void)swipe:(UISwipeGestureRecognizer*)recognizer direction:(UISwipeGestureRecognizerDirection)direction 
{
    if (recognizer && recognizer.state == UIGestureRecognizerStateEnded && !self.animatingCalendar) {
        if (direction == UISwipeGestureRecognizerDirectionLeft && !self.nextMonthButton.hidden) {
            // Left swipe shows next month
            [self showNextMonth:recognizer];
        }
        else if (direction == UISwipeGestureRecognizerDirectionRight) {
            // Right swipe shows previous month
            [self showPreviousMonth:recognizer];
        }
    }
}
                                                             
- (void)drawCalendarForDate:(NSDate*)date
{
    // Clean out previous calendar
    for (UIView *button in self.dayCells) {
        [button removeFromSuperview];
    }
    [self.dayCells removeAllObjects];
    if (self.todayLabelBackground) {
        [self.todayLabelBackground removeFromSuperview];
        self.todayLabelBackground = nil;
    }
        
    // Bitwise OR of NSDateFlags to indicate which date components are required
    unsigned unitFlags = (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit);
    NSDateComponents *dateComponents = [self.gregorianCalendar components: unitFlags fromDate:date];
    
    // Ensure date is for the first of the month
    if (dateComponents.day != 1) {
        [dateComponents setDay:1];
        [dateComponents setWeekday:NSUndefinedDateComponent];
        // Create an absolute date for the first of the month
        self.displayedMonth = [self.gregorianCalendar dateFromComponents:dateComponents];
        // Update dateComponents to get weekday
        dateComponents = [self.gregorianCalendar components:unitFlags fromDate:self.displayedMonth];
    }
    else {
        // ensure displayedMonth is up-to-date
        self.displayedMonth = date;
    }
    
    NSDictionary *month = [[NSDictionary alloc] init];
    for (NSDictionary *m in self.calendar) {
        if ([[m objectForKey:@"year"] intValue] == dateComponents.year && [[m objectForKey:@"month"] intValue] == dateComponents.month) {
            month = m;
        }
    }

    // Updated count labels with number of gratitudes for the month
    [self updateCountLabels:[[month objectForKey:@"count"] integerValue]];
    
    // Set that contains the days with gratitudes
    NSSet *gratitudeDays = [month objectForKey:@"days"];
    
    // Show month and year
    // Note monthSymbols is 0-based, dateComponents are 1-based
    self.monthLabel.text = [NSString stringWithFormat:@"%@, %d", [[self.interfaceDateFormatter monthSymbols] objectAtIndex:(dateComponents.month - 1)], dateComponents.year];
    
    // Calculate how many days are in the month
    NSRange daysInMonth = [self.gregorianCalendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:self.displayedMonth];
    
    NSUInteger offset = [dateComponents weekday] - 1;
    
    // Used to show current date on calendar
    NSDateComponents *currentDateComponents = [self.gregorianCalendar components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:[NSDate date]];
    if (dateComponents.year != currentDateComponents.year || dateComponents.month != currentDateComponents.month) {
        currentDateComponents = nil;
    }
    
    // Draw the calendar
    UILabel *label = nil;
    UIButton *button = nil;
    CGRect frame;
    frame.size.height = 44;
    frame.size.width = 44;
    int day = 0;
    for (int i = 0; i < 6; i++) {
        for (int j = 0; j < 7; j++) {
            day = (7 * i) + j - offset;
            if (day >= 0 && day < daysInMonth.length) {
                // Position the element
                frame.origin.x = 44 * j + CONTAINER_HORIZONTAL_MARGIN;
                frame.origin.y = 44 * i + CONTAINER_VERTICAL_MARGIN;
                if ([gratitudeDays containsObject:[NSNumber numberWithInt:day + 1]]) {
                    // Day has gratitudes, use button
                    button = [UIButton buttonWithType:UIButtonTypeCustom];
                    button.frame = frame;
                    
                    if (currentDateComponents && currentDateComponents.day == (day + 1)) {
                        [button setBackgroundImage:[UIImage imageNamed:@"button_calendar_today.png"] forState:UIControlStateNormal];
                    }
                    else {
                        [button setBackgroundImage:[UIImage imageNamed:@"button_calendar_day.png"] forState:UIControlStateNormal];
                    }
                    
                    
                    [button setTitle:[NSString stringWithFormat:@"%d", day + 1] forState:UIControlStateNormal];
                    [button setTitleColor:[UIColor tableTextColour] forState:UIControlStateNormal];
                    [[button titleLabel] setFont:[UIFont boldSystemFontOfSize:16.0]];
                    [button addTarget:self action:@selector(showDay:) forControlEvents:UIControlEventTouchUpInside];
                    [[self containerView] addSubview:button];
                    [self.dayCells addObject:button];
                    
                    //button.layer.borderWidth = 1;
                }
                else {
                    // Day has no gratitudes, use label
                    
                    label = [[UILabel alloc] init];
                    if (currentDateComponents && currentDateComponents.day == (day + 1)) {
                        label.backgroundColor = [UIColor clearColor];
                        label.opaque = NO;
                        self.todayLabelBackground = [[UIImageView alloc] initWithFrame:frame];
                        self.todayLabelBackground.image = [UIImage imageNamed:@"bg_calendar_today.png"];
                        [self.containerView addSubview:self.todayLabelBackground];
                    }
                    
                    
                    label.textAlignment = NSTextAlignmentCenter;
                    label.frame = frame;
                    label.text = [NSString stringWithFormat:@"%d", day + 1];
                    label.font = [UIFont boldSystemFontOfSize:16.0];
                    label.textColor = [UIColor tableTextColour];
                    [[self containerView] addSubview:label];
                    [self.dayCells addObject:label];
                    
                    //label.layer.borderWidth = 1;
                }
            }
        }
    }
    
    // Resize container to fit
    CGRect containerFrame = self.containerView.frame;
    UIView *lastDay = (UIView*)[self.dayCells lastObject];
    containerFrame.size.height = lastDay.frame.origin.y + lastDay.frame.size.height + (CONTAINER_VERTICAL_MARGIN * 2);
    self.containerView.frame = containerFrame;
}

#pragma mark - Actions

- (void)showDay:(id)sender
{
    // Get date from button that was pressed
    NSString *day = ((UIButton*)sender).titleLabel.text;
    NSDateComponents *buttonDateComponents = [self.gregorianCalendar components:(NSYearCalendarUnit | NSMonthCalendarUnit) fromDate:self.displayedMonth];
    buttonDateComponents.day = [day integerValue];
    NSDate *buttonDate = [self.gregorianCalendar dateFromComponents:buttonDateComponents];
    
    // Create and show view controller
    GratitudesForDateViewController *viewController = [[GratitudesForDateViewController alloc] init];
    viewController.user = self.user;
    viewController.date = buttonDate;
    
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle: @"Back" style: UIBarButtonItemStyleBordered target: nil action: nil];
    [[self navigationItem] setBackBarButtonItem: newBackButton];

    [self.pushedViewControllers addObject:viewController];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)createGratitude:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:CreatingGratitudeNotification object:nil];
}

- (IBAction)showNextMonth:(id)sender
{
    NSDateComponents *dateComponents = [self.gregorianCalendar components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:self.displayedMonth];
    [dateComponents setMonth:dateComponents.month + 1];
    // Increment year if neccessary
    if (dateComponents.month > 12) {
        [dateComponents setMonth:dateComponents.month - 12];
        [dateComponents setYear:dateComponents.year + 1];
    }
    
    self.displayedMonth = [self.gregorianCalendar dateFromComponents:dateComponents];
    NSDateComponents *currentMonth = [self.gregorianCalendar components:(NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:[NSDate date]];
    if (dateComponents.month == currentMonth.month && dateComponents.year == currentMonth.year) {
        // Prevent people from navigating to future months
        self.nextMonthButton.hidden= YES;
    }
    self.animatingCalendar = YES;
    // Animate previous month out and new month in
    [UIView animateWithDuration:SLIDE_ANIMATION_DURATION delay:0 options:UIViewAnimationCurveEaseIn animations:^{
        self.containerView.frame = CGRectMake(-325, self.containerView.frame.origin.y, self.containerView.frame.size.width, self.containerView.frame.size.height);
    } completion:^(BOOL finished) {
        self.containerView.frame = CGRectMake(325, self.containerView.frame.origin.y, self.containerView.frame.size.width, self.containerView.frame.size.height);
        [self drawCalendarForDate:self.displayedMonth];
        [UIView animateWithDuration:SLIDE_ANIMATION_DURATION delay:0 options:UIViewAnimationCurveEaseOut animations:^{
            self.containerView.frame = CGRectMake(5, self.containerView.frame.origin.y, self.containerView.frame.size.width, self.containerView.frame.size.height);
        } completion:^(BOOL finished) {
            self.animatingCalendar = NO;
        }];
    }];
}

- (IBAction)showPreviousMonth:(id)sender 
{
    self.currentMonthIndex += 1;
    
    BOOL shouldUpdateIndex = YES;
    NSDateComponents *components = [self.gregorianCalendar components:0 fromDate:self.displayedMonth];
    [components setMonth:components.month - 1];
    if (components.month < 1) {
        [components setMonth:components.month + 12];
        [components setYear:components.year - 1];
    }
    for (NSDictionary *m in self.calendar) {
        if ([[m objectForKey:@"year"] intValue] == components.year && [[m objectForKey:@"month"] intValue] == components.month) {
            shouldUpdateIndex = NO;
            break;
        }
    }
    if(shouldUpdateIndex) {
        [self updateIndex];
    }
    
    self.nextMonthButton.hidden = NO;
    NSDateComponents *dateComponents = [self.gregorianCalendar components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:self.displayedMonth];
    [dateComponents setMonth:dateComponents.month - 1];
    if (dateComponents.month < 1) {
        [dateComponents setMonth:dateComponents.month + 12];
        [dateComponents setYear:dateComponents.year - 1];
    }
    self.displayedMonth = [self.gregorianCalendar dateFromComponents:dateComponents];
    
    // Animate previous month out and new month in
    self.animatingCalendar = YES;
    [UIView animateWithDuration:SLIDE_ANIMATION_DURATION delay:0 options:UIViewAnimationCurveEaseIn animations:^{
        self.containerView.frame = CGRectMake(325, self.containerView.frame.origin.y, self.containerView.frame.size.width, self.containerView.frame.size.height);
    } completion:^(BOOL finished) {
        self.containerView.frame = CGRectMake(-325, self.containerView.frame.origin.y, self.containerView.frame.size.width, self.containerView.frame.size.height);
        [self drawCalendarForDate:self.displayedMonth];
        [UIView animateWithDuration:SLIDE_ANIMATION_DURATION delay:0 options:UIViewAnimationCurveEaseOut animations:^{
            self.containerView.frame = CGRectMake(5, self.containerView.frame.origin.y, self.containerView.frame.size.width, self.containerView.frame.size.height);
        } completion:^(BOOL finished) {
            self.animatingCalendar = NO;
        }];
    }];
}

- (void)updateCountLabels:(NSInteger)count 
{
    // Update and lay out count labels
    self.countLabel2.text = [NSString stringWithFormat:@"%d", count];
    
    CGSize countLabel1Size = [self.countLabel1.text sizeWithFont:self.countLabel1.font];
    CGSize countLabel2Size = [self.countLabel2.text sizeWithFont:self.countLabel2.font];
    CGSize countLabel3Size = [self.countLabel3.text sizeWithFont:self.countLabel3.font];
    
    self.countLabel1.frame = CGRectMake(0, self.countLabel1.frame.origin.y, countLabel1Size.width + 2, countLabel2Size.height + 2);
    self.countLabel2.frame = CGRectMake(self.countLabel1.frame.origin.x + self.countLabel1.frame.size.width, self.countLabel2.frame.origin.y, countLabel2Size.width + 2, countLabel2Size.height + 2);
    self.countLabel3.frame = CGRectMake(self.countLabel2.frame.origin.x + self.countLabel2.frame.size.width, self.countLabel3.frame.origin.y, countLabel3Size.width + 2, countLabel3Size.height + 2);
    
    self.labelContainerView.frame = CGRectMake(self.labelContainerView.frame.origin.x, self.labelContainerView.frame.origin.y, self.countLabel1.frame.size.width + self.countLabel2.frame.size.width + self.countLabel3.frame.size.width, self.countLabel1.frame.size.height);
    self.labelContainerView.center = CGPointMake(self.view.center.x, self.labelContainerView.center.y);
}

- (void)viewDidUnload {
    [self setCreateGratitudeButton:nil];
    [super viewDidUnload];
}
@end
