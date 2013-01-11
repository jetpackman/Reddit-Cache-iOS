//
//  WordCloudViewController.m
//  onething
//
//  Created by Anthony Wong on 12-05-14.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import "WordCloudViewController.h"

@implementation WordCloudViewController
@synthesize webView = _webView;
@synthesize hud = _hud;
@synthesize user = _user;
@synthesize gregorianCalendar = _gregorianCalendar;
@synthesize interfaceDateFormatter = _interfaceDateFormatter;
@synthesize displayedMonth = _displayedMonth;
@synthesize monthLabel = _monthLabel;
@synthesize previousMonthButton = _previousMonthButton;
@synthesize nextMonthButton = _nextMonthButton;
@synthesize animatingCalendar = _animatingCalendar;
@synthesize createGratitudeButton = _createGratitudeButton;

#define SLIDE_ANIMATION_DURATION 0.3f

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.displayedMonth = [NSDate date];
    [self.view setAccessibilityLabel:@"Word Cloud Screen"];
    [self setTitle:@"Word Cloud"];
    self.gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    self.interfaceDateFormatter = [[NSDateFormatter alloc] init];
    [self.interfaceDateFormatter setDateFormat:@"yyyy-MM-dd"];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/api/v1/words/cloud.html?api_key=%@&date=%@",[OnethingClientAPI apiBaseURL], self.user.apiKey, [self.interfaceDateFormatter stringFromDate:self.displayedMonth]]]]];
    [self.interfaceDateFormatter setDateFormat:@"MMMM, yyyy"];
    self.monthLabel.text = [self.interfaceDateFormatter stringFromDate:self.displayedMonth];

    self.nextMonthButton.hidden= YES;
    
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
    
}

- (IBAction)createGratitude:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:CreatingGratitudeNotification object:nil];
}

- (void)createGratitudeSwiped:(UISwipeGestureRecognizer*)recognizer
{
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

- (IBAction)showNextMonth:(id)sender 
{
    self.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view insertSubview:self.hud aboveSubview:self.view];
    self.hud.dimBackground = YES;
    self.hud.mode = MBProgressHUDModeIndeterminate;
    self.hud.labelText = @"Loading...";
    [self.hud show:YES];
    
    NSDateComponents *dateComponents = [self.gregorianCalendar components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:self.displayedMonth];
    [dateComponents setMonth:dateComponents.month + 1];
    // Increment year if neccessary
    if (dateComponents.month > 12) {
        [dateComponents setMonth:dateComponents.month - 12];
        [dateComponents setYear:dateComponents.year + 1];
    }
    
    self.displayedMonth = [self.gregorianCalendar dateFromComponents:dateComponents];

    self.animatingCalendar = YES;
    // Animate previous month out and new month in
    [UIView animateWithDuration:SLIDE_ANIMATION_DURATION delay:0 options:UIViewAnimationCurveEaseIn animations:^{
        self.webView.frame = CGRectMake(-325, self.webView.frame.origin.y, self.webView.frame.size.width, self.webView.frame.size.height);
    } completion:^(BOOL finished) {
        self.webView.frame = CGRectMake(325, self.webView.frame.origin.y, self.webView.frame.size.width, self.webView.frame.size.height);
        [self.interfaceDateFormatter setDateFormat:@"yyyy-MM-dd"];
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/api/v1/words/cloud.html?api_key=%@&date=%@", [OnethingClientAPI apiBaseURL], self.user.apiKey, [self.interfaceDateFormatter stringFromDate:self.displayedMonth]]]]];    
        [self.interfaceDateFormatter setDateFormat:@"MMMM, yyyy"];
        self.monthLabel.text = [self.interfaceDateFormatter stringFromDate:self.displayedMonth];
        [UIView animateWithDuration:SLIDE_ANIMATION_DURATION delay:0 options:UIViewAnimationCurveEaseOut animations:^{
            self.webView.frame = CGRectMake(5, self.webView.frame.origin.y, self.webView.frame.size.width, self.webView.frame.size.height);
        } completion:^(BOOL finished) {
            NSDateComponents *currentMonth = [self.gregorianCalendar components:(NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:[NSDate date]];
            if (dateComponents.month == currentMonth.month && dateComponents.year == currentMonth.year) {
                // Prevent people from navigating to future months
                self.nextMonthButton.hidden= YES;
            }
            [self.hud hide:YES];
            self.animatingCalendar = NO;
        }];
    }];
}

- (IBAction)showPreviousMonth:(id)sender 
{    
    
    self.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view insertSubview:self.hud aboveSubview:self.view];
    self.hud.dimBackground = YES;
    self.hud.mode = MBProgressHUDModeIndeterminate;
    self.hud.labelText = @"Loading...";
    [self.hud show:YES];
    
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
        self.webView.frame = CGRectMake(325, self.webView.frame.origin.y, self.webView.frame.size.width, self.webView.frame.size.height);
    } completion:^(BOOL finished) {
        self.webView.frame = CGRectMake(-325, self.webView.frame.origin.y, self.webView.frame.size.width, self.webView.frame.size.height);
        [self.interfaceDateFormatter setDateFormat:@"yyyy-MM-dd"];
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/api/v1/words/cloud.html?api_key=%@&date=%@", [OnethingClientAPI apiBaseURL], self.user.apiKey, [self.interfaceDateFormatter stringFromDate:self.displayedMonth]]]]];
        [self.interfaceDateFormatter setDateFormat:@"MMMM, yyyy"];
        self.monthLabel.text = [self.interfaceDateFormatter stringFromDate:self.displayedMonth];
        [UIView animateWithDuration:SLIDE_ANIMATION_DURATION delay:0 options:UIViewAnimationCurveEaseOut animations:^{
            self.webView.frame = CGRectMake(5, self.webView.frame.origin.y, self.webView.frame.size.width, self.webView.frame.size.height);
        } completion:^(BOOL finished) {
            [self.hud hide:YES];
            self.animatingCalendar = NO;
        }];
    }];
}
- (void)viewDidUnload {
    [self setCreateGratitudeButton:nil];
    [super viewDidUnload];
}
@end
