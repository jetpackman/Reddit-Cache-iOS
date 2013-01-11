//
//  WordCloudViewController.h
//  onething
//
//  Created by Anthony Wong on 12-05-14.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface WordCloudViewController : BaseViewController
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet MBProgressHUD *hud;
@property (nonatomic, strong) User* user;
@property (nonatomic, strong) NSCalendar *gregorianCalendar;
@property (nonatomic, strong) NSDateFormatter *interfaceDateFormatter;
@property (nonatomic, strong) NSDate *displayedMonth;
@property (nonatomic, weak) IBOutlet UILabel *monthLabel;
@property (nonatomic, weak) IBOutlet UIButton *previousMonthButton;
@property (nonatomic, weak) IBOutlet UIButton *nextMonthButton;
@property (nonatomic, assign) BOOL animatingCalendar;
@property (weak, nonatomic) IBOutlet UIButton *createGratitudeButton;

- (IBAction)createGratitude:(id)sender;
- (void)swipe:(UISwipeGestureRecognizer*)recognizer direction:(UISwipeGestureRecognizerDirection)direction;
- (IBAction)showNextMonth:(id)sender;
- (IBAction)showPreviousMonth:(id)sender;
@end
