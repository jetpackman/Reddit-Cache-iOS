//
//  GratitudeMapViewController.h
//  onething
//
//  Created by Anthony Wong on 12-05-10.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MKMapView+ZoomLevel.h"
#import "BaseViewController.h"

@interface GratitudeMapViewController : BaseViewController <CLLocationManagerDelegate, MKMapViewDelegate, UISearchBarDelegate>
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) MBProgressHUD *hud;
@property (nonatomic, assign) CLLocationCoordinate2D mapCenterCoordinate;
@property (nonatomic, strong) CLLocation* userLocation;
@property (nonatomic, strong) CLLocationManager* locationManager;
@property (nonatomic, strong) NSMutableArray* gratitudeBins;
@property (nonatomic, strong) NSOperation* updateOperation;
@property (nonatomic, strong) User* user;
@property (nonatomic, assign) BOOL hasFinishedInit;
@property (nonatomic, assign) BOOL mine;
@property (weak, nonatomic) IBOutlet UIButton *createGratitudeButton;
@property (nonatomic, strong) UIBarButtonItem *flyButton;
@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;
@property (nonatomic, assign) BOOL searchButtonShown;

- (IBAction)createGratitude:(id)sender;
-(void) reloadGratitudes;
- (void)startLocationMonitoring;
- (void)stopLocationMonitoring;
- (void)performStringGeocode:(id)sender;
-(void) showSearchBar;

@end
