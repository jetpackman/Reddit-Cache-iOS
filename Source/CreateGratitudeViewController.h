//
//  CreateGratitudeViewController.h
//  onething
//
//  Created by Dane Carr on 12-02-16.
//  Copyright (c) 2012 1THING. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "Gratitude.h"
#import "User.h"
#import "CoreLocation/CoreLocation.h"

typedef void(^CreateGratitudeCallback)(Gratitude* gratitude);
typedef void(^AnimationCompleteCallback)();
typedef void(^CanceledGratitudeCallback)();
@interface CreateGratitudeViewController : UIViewController <UITextViewDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong) User* user;
@property (nonatomic, strong) Gratitude *editGratitude;
@property (nonatomic, copy) CreateGratitudeCallback createGratitudeCallback;
@property (nonatomic, assign) BOOL locationEnabled;
@property (nonatomic, strong) NSOperation *geocodeOperation;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, strong) NSString *neighbourhood;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, assign) CGFloat textHeight;
@property (nonatomic, assign) NSInteger maxTextFieldContainerSize;
@property (nonatomic, strong) UIColor *redTextColour;
@property (nonatomic, weak) IBOutlet UITextView *textField;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *doneBarButtonItem;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *cancelBarButtonItem;
@property (nonatomic, weak) IBOutlet UILabel *characterCountLabel;
@property (nonatomic, weak) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, weak) IBOutlet UIButton *locationButton;
@property (nonatomic, weak) IBOutlet UIButton *removeLocationButton;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, weak) IBOutlet UIView *textFieldFooter;
@property (nonatomic, weak) IBOutlet UIView *textFieldContainer;
@property (nonatomic, copy)AnimationCompleteCallback animationCompleteCallback;
@property (nonatomic, copy) CanceledGratitudeCallback canceledGratitudeCallback;
- (IBAction)createGratitude:(id)sender;
- (IBAction)cancelGratitudeCreation:(id)sender;
- (IBAction)locationButtonPressed:(id)sender;
- (IBAction)removeLocationButtonPressed:(id)sender;
- (void)fadeIn;
- (void)startLocationMonitoring;
- (void)stopLocationMonitoring;
- (void)registerForKeyboardNotifications;
- (void)turnOnLocationButton;
- (void)turnOffLocationButton;
@end
