//
//  CreateGratitudeViewController.m
//  onething
//
//  Created by Dane Carr on 12-02-16.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import "CreateGratitudeViewController.h"
#import "TWGMenuController.h"
#import "TWGDrawerViewController.h"
#import "GoogleMapsClientAPI.h"

@implementation CreateGratitudeViewController

@synthesize user = _user;
@synthesize editGratitude = _editGratitude;
@synthesize textField = _textField;
@synthesize characterCountLabel = _characterCountLabel;
@synthesize backgroundImageView = _backgroundImageView;
@synthesize doneBarButtonItem = _doneBarButtonItem;
@synthesize cancelBarButtonItem = _cancelBarButtonItem;
@synthesize locationButton = _locationButton;
@synthesize removeLocationButton = _removeLocationButton;
@synthesize activityIndicator = _activityIndicator;
@synthesize textFieldFooter = _textFieldFooter;
@synthesize textFieldContainer = _textFieldContainer;
@synthesize locationEnabled = _locationEnabled;
@synthesize geocodeOperation = _geocodeOperation;
@synthesize createGratitudeCallback = _createGratitudeCallback;
@synthesize locationManager = _locationManager;
@synthesize location = _location;
@synthesize neighbourhood = _neighbourhood;
@synthesize city = _city;
@synthesize textHeight = _textHeight;
@synthesize maxTextFieldContainerSize = _maxTextFieldContainerSize;
@synthesize redTextColour = _redTextColour;
@synthesize animationCompleteCallback = _animationCompleteCallback;
@synthesize canceledGratitudeCallback = _canceledGratitudeCallback;

#define TEXT_FIELD_WIDTH 310
#define TEXT_FIELD_FOOTER_HEIGHT 44

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self registerForKeyboardNotifications];
    
    self.removeLocationButton.hidden = YES;
    self.activityIndicator.hidden = YES;
    
    UIImage *removeLocationButtonBackground = [[UIImage imageNamed:@"button_remove_location.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(13, 20, 13, 20)];
    [self.removeLocationButton setBackgroundImage:removeLocationButtonBackground forState:UIControlStateNormal];
    
    UIImage *barButtonBackground = [[UIImage imageNamed:@"bar_button_save.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(14, 6, 14, 5)];
    UIImage *barButtonBackgroundHighlighted = [[UIImage imageNamed:@"bar_button_save_tap.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(14, 6, 14, 5)];
    
    [self.doneBarButtonItem setBackgroundImage:barButtonBackground forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [self.doneBarButtonItem setBackgroundImage:barButtonBackgroundHighlighted forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    [self.doneBarButtonItem setAccessibilityLabel:@"Done"];
    
    UIImage *locationButtonBackground = [[UIImage imageNamed:@"button_location.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(13, 6, 13, 5)];
    [self.locationButton setBackgroundImage:locationButtonBackground forState:UIControlStateNormal];
    
    self.redTextColour = [UIColor colorWithRed:224.0/255.0 green:71.0/255.0 blue:71.0/255.0 alpha:1];
    
    self.textHeight = 36;
    
    self.textField.scrollEnabled = NO;
    
    [self.doneBarButtonItem setEnabled:NO];
    self.textFieldContainer.hidden = YES;

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    UIImage *image;
    
    if ([defaults objectForKey:BackgroundImage]) {
        image = [UIImage imageWithData:[defaults objectForKey:BackgroundImage]];
    }
    else {
        image = [UIImage imageNamed:@"bg_create_gratitude.png"];
    }
    self.backgroundImageView.image = image;
    
    self.locationManager = nil;
    self.geocodeOperation = nil;
    
    if (![CLLocationManager locationServicesEnabled] || 
        ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized &&
        [CLLocationManager authorizationStatus] != kCLAuthorizationStatusNotDetermined)) {
        self.locationButton.enabled = NO;
    }
    else if (self.editGratitude) {
        [self.doneBarButtonItem setEnabled:YES];
        if (self.editGratitude.hasLocation) {
            self.neighbourhood = self.editGratitude.neighbourhood;
            self.city = self.editGratitude.city;
            [self.removeLocationButton setTitle:self.neighbourhood forState:UIControlStateNormal];
            
            CGRect frame = self.removeLocationButton.frame;
            frame.size.width = [self.neighbourhood sizeWithFont:self.removeLocationButton.titleLabel.font forWidth:185 lineBreakMode:NSLineBreakByTruncatingTail].width + 45;
            self.removeLocationButton.frame = frame;
            self.locationButton.hidden = YES;
            
            [self.activityIndicator stopAnimating];
            self.activityIndicator.hidden = YES;
            self.removeLocationButton.hidden = NO;
            
            self.location = [[CLLocation alloc] initWithLatitude:self.editGratitude.location.latitude longitude:self.editGratitude.location.longitude];
            self.locationEnabled = YES;
        }
        else {
            [self turnOffLocationButton];
            self.locationEnabled = NO;
        }
        
        self.textField.text = self.editGratitude.body;
    
        
        CGRect frame = self.textFieldContainer.frame;
        
        frame.size.height = frame.size.height + (self.textField.contentSize.height - self.textHeight);
        
        self.textHeight = self.textField.contentSize.height;
        self.textFieldContainer.frame = frame;
        
    }
    else if (![defaults boolForKey:GratitudeLocationEnabled]) {
        [self turnOffLocationButton];
    }
    else if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusNotDetermined) {
        [self turnOnLocationButton];
    }
    
    self.characterCountLabel.text = [NSString stringWithFormat:@"%d", self.textField.text.length];
    [self.characterCountLabel setAccessibilityLabel:[NSString stringWithFormat:@"Character count: %d", self.textField.text.length]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) registerForKeyboardNotifications 
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
}
    
- (void)keyboardWasShown:(NSNotification*)notification
{
    NSDictionary *info = [notification userInfo];
    NSInteger keyboardHeight = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
    
    NSInteger navBarHeight = 44;
    
    self.maxTextFieldContainerSize = self.view.frame.size.height - keyboardHeight - navBarHeight;
}

- (void)viewDidAppear:(BOOL)animated
{
    [self fadeIn];
    
    if (self.animationCompleteCallback != nil){
        self.animationCompleteCallback();
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)turnOnLocationButton 
{
    self.locationEnabled = YES;
    self.locationButton.hidden = YES;
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
    [self startLocationMonitoring];
}

- (void)turnOffLocationButton
{
    self.removeLocationButton.hidden = YES;
    self.removeLocationButton.titleLabel.text = @"";
    self.removeLocationButton.frame = self.locationButton.frame;
    self.locationButton.hidden = NO;
    self.locationEnabled = NO;
    self.geocodeOperation = nil;
    self.neighbourhood = nil;
    self.city = nil;
    [self stopLocationMonitoring];
}

-(void)startLocationMonitoring
{
    if ([CLLocationManager locationServicesEnabled] == NO || 
        ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized &&
         [CLLocationManager authorizationStatus] != kCLAuthorizationStatusNotDetermined) ) {
        // Skip location services setup if location services are unavailable or not authorized
        self.locationManager = nil;
        self.location = nil;
        self.locationButton.enabled = NO;
        return;
    }
    else {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        [self.locationManager startUpdatingLocation];
    }
}

- (void)stopLocationMonitoring
{
    if (self.locationManager) {
        [self.locationManager stopUpdatingLocation];
    }
}

#pragma mark - Gratitude

- (IBAction)createGratitude:(id)sender
{
    NSString *body = self.textField.text;

    if ([body isEqualToString:@""]) {
        return;
    }
    
    [self.cancelBarButtonItem setEnabled:NO];
    
    UIView *doneButtonView = self.doneBarButtonItem.customView;
    
    if (self.editGratitude) {
        self.editGratitude.body = body;
        
        if (!self.locationEnabled) {
            self.editGratitude.hasLocation = NO;
            self.editGratitude.location = CLLocationCoordinate2DMake(0, 0);
            self.editGratitude.neighbourhood = nil;
            self.editGratitude.city = nil;
        }
        else {
            self.editGratitude.hasLocation = YES;
            self.editGratitude.location = self.location.coordinate;
            self.editGratitude.neighbourhood = self.neighbourhood;
            self.editGratitude.city = self.city;
        }
        
        [[OnethingClientAPI sharedClient] editGratitude:self.editGratitude apiKey:self.user.apiKey startup:^(NSOperation *operation) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
                [activityIndicator startAnimating];
                [self.doneBarButtonItem setCustomView:activityIndicator];
                [self.textField resignFirstResponder];
            }];
        } success:^(Gratitude *gratitude) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self.locationManager stopMonitoringSignificantLocationChanges];
                [self.locationManager stopUpdatingLocation];
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setBool:self.locationEnabled forKey:GratitudeLocationEnabled];
                [defaults synchronize];
                
                self.createGratitudeCallback(gratitude); 

            }];
        } failure:^(NSHTTPURLResponse *response, NSError *error) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self.cancelBarButtonItem setEnabled:YES];
                [self.doneBarButtonItem setCustomView:doneButtonView];
                NSLog(@"[ERROR] Failed to edit gratitude: %@ %@", [response debugDescription], [error userInfo]);
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                hud.mode = MBProgressHUDModeText;
                hud.dimBackground = YES;
                hud.margin = 10.0f;
                hud.removeFromSuperViewOnHide = YES;
                hud.labelText = @"Failed to save gratitude";
                [hud hide:YES afterDelay:2];
            }];
        } completion:nil];
    }    
    else {
        [[OnethingClientAPI sharedClient] createGratitudeWithBody:body apiKey:self.user.apiKey location:(self.locationEnabled ? self.location : nil) neighbourhood:self.neighbourhood city:self.city startup:^(NSOperation* operation){
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
                [activityIndicator startAnimating];
                [self.doneBarButtonItem setCustomView:activityIndicator];
                [self.textField resignFirstResponder];
            }];
        }success:^(Gratitude *gratitude) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self.locationManager stopMonitoringSignificantLocationChanges];
                [self.locationManager stopUpdatingLocation];
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:[NSNumber numberWithBool:self.locationEnabled] forKey:GratitudeLocationEnabled];
                [defaults synchronize];
                
                self.createGratitudeCallback(gratitude);

            }];
        } failure:^(NSHTTPURLResponse *response, NSError *error) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self.cancelBarButtonItem setEnabled:YES];
                [self.doneBarButtonItem setCustomView:doneButtonView];
                NSLog(@"[ERROR] Failed to create gratitude: %@ %@", [response debugDescription], [error userInfo]);
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                hud.mode = MBProgressHUDModeText;
                hud.dimBackground = YES;
                hud.margin = 10.0f;
                hud.removeFromSuperViewOnHide = YES;
                hud.labelText = @"Failed to create gratitude";
                [hud hide:YES afterDelay:2];

            }];
        } completion:nil];
    }
}

- (IBAction)cancelGratitudeCreation:(id)sender
{
    
    //NSLog(@"Cancel clicked!");
    [self stopLocationMonitoring];
    
    if (self.geocodeOperation) {
        [self.geocodeOperation cancel];
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithBool:self.locationEnabled] forKey:GratitudeLocationEnabled];
    [defaults synchronize];
        
    self.canceledGratitudeCallback(nil);
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIButton Actions

- (IBAction)locationButtonPressed:(id)sender
{
    [self turnOnLocationButton];
}

- (IBAction)removeLocationButtonPressed:(id)sender
{
    TWGActionItem *cancelItem = [TWGActionItem actionItemWithTitle:@"Cancel"];
    TWGActionItem *removeLocation = [TWGActionItem actionItemWithTitle:@"Remove" block:^{
        [self turnOffLocationButton];
    }];
    
    TWGActionSheet *actionSheet = [TWGActionSheet actionSheetWithTitle:@"Remove location?" cancelItem:cancelItem destructiveItem:removeLocation otherItems:nil];
    [actionSheet showInView:self.view];
}

#pragma mark - UITextView Delegate

- (void)textViewDidChange:(UITextView *)textView 
{
    NSUInteger textLength = textView.text.length;

    self.characterCountLabel.text = [NSString stringWithFormat:@"%d", textLength];
    if (textLength > 0 && textLength <= 140) {
        [self.doneBarButtonItem setEnabled:YES];
        [self.characterCountLabel setTextColor:[UIColor tableTextColour]];
    }
    else {
        [self.doneBarButtonItem setEnabled:NO];
        if (textLength != 0) {
            [self.characterCountLabel setTextColor:self.redTextColour];
        }
    }
        
    if (self.textField.contentSize.height != self.textHeight) {
        NSInteger difference = self.textField.contentSize.height - self.textHeight;
        
        if (difference > 0) {
            if (self.textFieldContainer.frame.size.height + difference > self.maxTextFieldContainerSize) {
                
                if (self.textField.scrollEnabled == NO) {
                    // Ensure textFieldContainer does not go under keyboard
                    self.textField.scrollEnabled = YES;
                    [UIView animateWithDuration:0.1 animations:^{
                        CGRect frame = self.textFieldContainer.frame;
                        frame.size.height = self.maxTextFieldContainerSize;
                        ;
                        self.textFieldContainer.frame = frame;
                    } completion:^(BOOL finished) {
                        
                        [self.textField setContentOffset:CGPointMake(0, 3 + self.textField.contentSize.height - self.textField.frame.size.height) animated:YES];
                        //self.textField.scrollEnabled = YES;
                    }];
                }
                else {
                    [self.textField setContentOffset:CGPointMake(0, 3 + self.textField.contentSize.height - self.textField.frame.size.height) animated:YES];
                }
            }
            else {
                [UIView animateWithDuration:0.1 animations:^{
                    CGRect frame = self.textFieldContainer.frame;
                    frame.size.height = self.textField.contentSize.height + 44;
                    self.textFieldContainer.frame = frame;
                }];
            }
        }
        else {
            if (self.textField.contentSize.height <= self.textField.frame.size.height) {
                [UIView animateWithDuration:0.1 animations:^{
                    CGRect frame = self.textFieldContainer.frame;
                    if (self.textField.contentSize.height < 44) {
                        frame.size.height = 88;
                    }
                    else {
                        frame.size.height = self.textField.contentSize.height + 44;
                    }
                    self.textFieldContainer.frame = frame;
                } completion:^(BOOL finished) {
                    self.textField.scrollEnabled = NO;
                }];
            }
        }
        
        self.textHeight = self.textField.contentSize.height;
    }
}

- (void)fadeIn
{
    self.textFieldContainer.alpha = 0;
    self.textFieldContainer.hidden = NO;
    
    [UIView animateWithDuration:1 animations:^{
        self.textFieldContainer.alpha = 1;
    } completion:^(BOOL finished) {
        [self.textField becomeFirstResponder];
    }];
}

#pragma mark - CLLocationManager Delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    if (newLocation.horizontalAccuracy < 0) {
        return;
    }
    else if (newLocation.horizontalAccuracy < 1000 && !self.geocodeOperation && !self.neighbourhood) {
        [[GoogleMapsClientAPI sharedClient] neighbourhoodForLocation:newLocation startup:^(NSOperation* operation){
            self.geocodeOperation = operation;
        } success:^(NSString *neighbourhood, NSString *city) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                if ([neighbourhood isEqualToString:@"Area unavailable"]) {
                    return;
                }
                self.neighbourhood = neighbourhood;
                self.city = city;
                [self.removeLocationButton setTitle:neighbourhood forState:UIControlStateNormal];
                
                CGRect frame = self.removeLocationButton.frame;
                frame.size.width = [neighbourhood sizeWithFont:self.removeLocationButton.titleLabel.font forWidth:185 lineBreakMode:UILineBreakModeTailTruncation].width + 45;
                self.removeLocationButton.frame = frame;
                
                [self.activityIndicator stopAnimating];
                self.activityIndicator.hidden = YES;
                self.removeLocationButton.hidden = NO;
            }];
        } failure:^(NSHTTPURLResponse *response, NSError *error){
            NSLog(@"failed");
            [self turnOffLocationButton];
        } completion:^{
            self.geocodeOperation = nil;
        }];
    }
    self.location = newLocation;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if (error.code == kCLErrorDenied) {
        [self stopLocationMonitoring];
        self.locationManager = nil;
        self.location = nil;
        self.locationButton.enabled = NO;
        self.neighbourhood = nil;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[NSNumber numberWithBool:NO] forKey:GratitudeLocationEnabled];
    }
}

@end
