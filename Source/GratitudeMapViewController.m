//
//  GratitudeMapViewController.m
//  onething
//
//  Created by Anthony Wong on 12-05-10.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import "GratitudeMapViewController.h"

#import "OnethingClientAPI.h"
#import "Gratitude.h"
#import "GratitudeAnnotationView.h"
#import "GratitudesForBinViewController.h"


@implementation GratitudeMapViewController
@synthesize mapView = _mapView;
@synthesize hud = _hud;
@synthesize mapCenterCoordinate = _mapCenterCoordinate;
@synthesize userLocation = _userLocation;
@synthesize locationManager = _locationManager;
@synthesize gratitudeBins = _gratitudeBins;
@synthesize updateOperation = _updateOperation;
@synthesize hasFinishedInit = _hasFinishedInit;
@synthesize createGratitudeButton = _createGratitudeButton;
@synthesize user = _user;
@synthesize mine = _mine;
@synthesize searchBar = _searchBar;
@synthesize flyButton = _flyButton;
@synthesize searchButtonShown = _searchButtonShown;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self startLocationMonitoring];

    [self setTitle:@"Gratitude Map"];
    
    self.pushedViewControllers = [NSMutableArray array];
    
    [self.view setAccessibilityLabel:@"Map Screen"];
    self.hasFinishedInit = NO;
    
    self.searchButtonShown = NO;

    //Set the search bar behind the navigation bar when view first loads
    CGPoint centre = self.searchBar.center;
    [self.searchBar setCenter:(CGPointMake(centre.x, centre.y - 44))];
    
    UIImage *airplaneImage = [UIImage imageNamed:@"airplaneicon.png"];
    UIImage *bgNavButton = [UIImage imageNamed:@"bg_nav_button.png"];
    
    self.flyButton = [[UIBarButtonItem alloc] initWithImage:airplaneImage style:UIBarButtonItemStyleBordered target:self action:@selector(showSearchBar)];
    [self.flyButton setBackgroundImage:bgNavButton forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    [[self navigationItem] setRightBarButtonItem:self.flyButton];
    
    UISwipeGestureRecognizer *buttonSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(createGratitudeSwiped:)];
    buttonSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
    [self.createGratitudeButton addGestureRecognizer:buttonSwipeGestureRecognizer];
    self.mapCenterCoordinate = self.mapView.centerCoordinate;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[self pushedViewControllers] removeAllObjects];
    [self reloadGratitudes];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self stopLocationMonitoring];
}

- (void)viewDidUnload
{
    [self setMapView:nil];
    [self setCreateGratitudeButton:nil];
    [super viewDidUnload];
}


#pragma mark - UISearchBar Delegate
// called when keyboard search button pressed
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self performStringGeocode:searchBar];
}

-(void) showSearchBar {
    
    [self.searchBar sizeToFit];
    CGPoint centre = self.searchBar.center;
    
    if (self.searchButtonShown) {
        self.searchButtonShown = NO;
        
        [UIView animateWithDuration:0.3 animations:^{
            [self.searchBar setCenter:(CGPointMake(centre.x, centre.y - 44))];
            
        }];
        
    }
    else {
        self.searchButtonShown = YES;

        [UIView animateWithDuration:0.3 animations:^{
            [self.searchBar setCenter:(CGPointMake(centre.x, centre.y + 44))];
        }];
        
    }
    // dismiss the keyboard if it's currently open
    if ([self.searchBar isFirstResponder])
    {
        [self.searchBar resignFirstResponder];
    }
    
    
}

#pragma mark - Gratitudes
- (void)createGratitudeSwiped:(UISwipeGestureRecognizer*)recognizer
{
    [self createGratitude:recognizer];
}

- (IBAction)createGratitude:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:CreatingGratitudeNotification object:nil];
}

- (void)reloadGratitudes
{
    // Replace gratitude array with results
    if (self.updateOperation) {
        return;
    }
//        NSLog(@"%f,%f", self.mapView.centerCoordinate.latitude, self.mapView.centerCoordinate.longitude);
    [[OnethingClientAPI sharedClient] gratitudeMapForLocation:self.mapCenterCoordinate apiKey:self.user.apiKey startup:^(NSOperation *operation) {
        self.updateOperation = operation;
    } success:^(NSArray *gratitudeBins){
        self.gratitudeBins = [NSMutableArray arrayWithArray:gratitudeBins];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            // Add pins to map, and remove old pins
            // Existing pins already on the map
            for (id<MKAnnotation> annotation in self.mapView.annotations) {
                // Loop through the pins
                if (![annotation isKindOfClass:[MKUserLocation class]])
                    {
                    BOOL shouldKeep = NO;
                    for(GratitudeBin* bin in self.gratitudeBins) {
                        // Loop through all bins
                        
                        // If pin matches the bin...
                        if(((GratitudeBin*)annotation).coordinate.latitude == bin.coordinate.latitude &&
                           ((GratitudeBin*)annotation).coordinate.longitude == bin.coordinate.longitude &&
                           bin.mine == self.mine) {
                            shouldKeep = YES;
                        }
                    }
                    if(!shouldKeep) {
                        [self.mapView removeAnnotation:annotation];
                    }
                }
            }
            
            // New bins from the server
            for (GratitudeBin* bin in self.gratitudeBins) {
                if (bin.mine != self.mine) {
                    // Skip bins that don't match the 'mine' mode.
                    continue;
                }
                
                              
                // Go through new bins...
                BOOL alreadyExisting = NO;
                for(id<MKAnnotation> annotation in self.mapView.annotations) {
                    // Go through existing bins
                    if ([annotation isKindOfClass:[MKUserLocation class]]) {
                        [self.mapView addAnnotation:annotation];
                    }

                    // If the pin matches the bin
                    if(((GratitudeBin*)annotation).coordinate.latitude == bin.coordinate.latitude &&
                       ((GratitudeBin*)annotation).coordinate.longitude == bin.coordinate.longitude &&
                       ![annotation isKindOfClass:[MKUserLocation class]]) {
                        alreadyExisting = YES;
                    }
                }
                if(!alreadyExisting) {
                    [self.mapView addAnnotation:bin];
                }
            }
        }];
//        self.mapCenterCoordinate = self.mapView.centerCoordinate;
    } failure:^(NSHTTPURLResponse *response, NSError *error){
        NSLog(@"[ERROR] Failed to retrieve locations: %@ %@", [response debugDescription], [error userInfo]);
    } completion:^{
        self.updateOperation = nil;
    }];
}


#pragma mark - MKMapView Delegate
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if (annotation == mapView.userLocation) {
        return nil;
    }
    
    GratitudeBin* myAnnotation = (GratitudeBin*)annotation;
    GratitudeAnnotationView* annotationView = nil;
    if (myAnnotation.gratitudeType == MyGratitudeAnnotationType) {
        annotationView = (GratitudeAnnotationView*) [self.mapView dequeueReusableAnnotationViewWithIdentifier:MyGratitudeAnnotationIdentifier];
        
        if (annotationView == nil){
            annotationView = [[GratitudeAnnotationView alloc] initWithAnnotation:myAnnotation reuseIdentifier:MyGratitudeAnnotationIdentifier];
        }
        
    } else {
        annotationView = (GratitudeAnnotationView*) [self.mapView dequeueReusableAnnotationViewWithIdentifier:OtherGratitudeAnnotationIdentifier];
        
        if (annotationView == nil){
            annotationView = [[GratitudeAnnotationView alloc] initWithAnnotation:myAnnotation reuseIdentifier:OtherGratitudeAnnotationIdentifier];
        }
    }
    if (annotationView != nil){
        [annotationView.countLabel setText:[NSString stringWithFormat:@"%d", myAnnotation.gratCount]];
        
        [annotationView setCanShowCallout:YES];
        [annotationView setEnabled:YES];
        
        annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        annotationView.canShowCallout = YES;
    }

    return annotationView;
    
}
- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    float offset = 0;
    for (MKAnnotationView* aV in views) {
        __block GratitudeAnnotationView* annotationView = (GratitudeAnnotationView*) aV;
        CGRect endFrame = annotationView.frame;
        annotationView.frame = CGRectMake(aV.frame.origin.x, aV.frame.origin.y - 480.0, aV.frame.size.width, aV.frame.size.height);
        [UIView animateWithDuration:0.45
                              delay:offset
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             [annotationView setFrame:endFrame];
                         }
                         completion:nil
         ];
        offset += 0.05;
    }
}

- (void)mapView:(MKMapView *)_mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    GratitudeBin* clickedBin = (GratitudeBin*) view.annotation;
    
    GratitudesForBinViewController* gratitudesForBinVC = [[GratitudesForBinViewController alloc] init];
    gratitudesForBinVC.user = self.user;
    gratitudesForBinVC.neighbourhood = clickedBin.neighbourhood;
    gratitudesForBinVC.city = clickedBin.city;
    gratitudesForBinVC.mine = clickedBin.mine;
    gratitudesForBinVC.gratCount = clickedBin.gratCount;
    gratitudesForBinVC.publicGratCount = clickedBin.publicGratCount;
    
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle: @"Back" style: UIBarButtonItemStyleBordered target: nil action: nil];
    [[self navigationItem] setBackBarButtonItem: newBackButton];
    
    
    [self.pushedViewControllers addObject:gratitudesForBinVC];
    [self.navigationController pushViewController:gratitudesForBinVC animated:YES];
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated 
{    
//    double latDiff = self.mapCenterCoordinate.latitude - self.mapView.centerCoordinate.latitude;
//    double lngDiff = self.mapCenterCoordinate.longitude - self.mapView.centerCoordinate.longitude;
//    double diffHypotenuse = sqrt(latDiff*latDiff + lngDiff*lngDiff);
//    if(diffHypotenuse > 0.01 && self.hasFinishedInit) {
    // dismiss the keyboard if it's currently open
    if ([self.searchBar isFirstResponder])
    {
        [self.searchBar resignFirstResponder];
    }
    
    if( self.hasFinishedInit) {
        self.mapCenterCoordinate = self.mapView.centerCoordinate;
        [self reloadGratitudes];
    }
    
    
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    if([self.mapView zoomLevel]<8) {
        [self.mapView setCenterCoordinate:[self.mapView centerCoordinate] zoomLevel:8 animated:YES];
        self.mapCenterCoordinate = self.mapView.centerCoordinate;
    }
}



-(void)startLocationMonitoring
{
    if ([CLLocationManager locationServicesEnabled] == NO ||
        ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized &&
         [CLLocationManager authorizationStatus] != kCLAuthorizationStatusNotDetermined) ) {
            // Skip location services setup if location services are unavailable or not authorized
            self.locationManager = nil;
            self.userLocation = nil;
            return;
        }
    else {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.distanceFilter = kCLDistanceFilterNone;
        self.locationManager.pausesLocationUpdatesAutomatically = NO;
        
        self.hud = [[MBProgressHUD alloc] initWithView:self.mapView];
        [self.view insertSubview:self.hud aboveSubview:self.mapView];
        self.hud.dimBackground = YES;
        self.hud.mode = MBProgressHUDModeIndeterminate;
        self.hud.labelText = @"Retrieving Location...";
        [self.hud show:YES];
        [self.locationManager startMonitoringSignificantLocationChanges];
        [self.locationManager startUpdatingLocation];
    }
}

- (void)stopLocationMonitoring
{
    if (self.locationManager) {
        [self.hud hide:YES afterDelay:0.2];
        [self.locationManager stopUpdatingLocation];
        [self.locationManager stopMonitoringSignificantLocationChanges];
    }
}

#pragma mark - CLLocationManager Delegate

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *newLocation = [locations objectAtIndex:[locations count] - 1];
        
    if (newLocation.horizontalAccuracy < 0) {
        return;
    } else if (newLocation.horizontalAccuracy < 1000){
        self.userLocation = newLocation;
        [self.hud hide:YES];
        [self stopLocationMonitoring];
        [self.mapView setCenterCoordinate:newLocation.coordinate zoomLevel:12 animated:NO];
        self.mapCenterCoordinate = self.mapView.centerCoordinate;
        [self reloadGratitudes];
        self.hasFinishedInit = YES;
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if (error.code == kCLErrorDenied) {
        [self stopLocationMonitoring];
        self.locationManager = nil;
        self.userLocation = nil;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[NSNumber numberWithBool:NO] forKey:GratitudeLocationEnabled];
    }
}

#pragma mark - Geocode

- (void)performStringGeocode:(id)sender
{
    // dismiss the keyboard if it's currently open
    if ([self.searchBar isFirstResponder])
    {
        [self.searchBar resignFirstResponder];
    }
        
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];

        // don't use a hint region
        [geocoder geocodeAddressString:self.searchBar.text completionHandler:^(NSArray *placemarks, NSError *error) {
            NSLog(@"geocodeAddressString:completionHandler: Completion Handler called!");
            if (error)
            {
                NSLog(@"Geocode failed with error: %@", error);
//                [self displayError:error];
                return;
            }
            
            NSLog(@"Received placemarks: %@", placemarks);
            CLPlacemark *placemark = [placemarks lastObject];
            [self.mapView setCenterCoordinate: placemark.location.coordinate zoomLevel:8 animated:NO];
            self.mapCenterCoordinate = self.mapView.centerCoordinate;
            [self reloadGratitudes];

        }];

}


@end