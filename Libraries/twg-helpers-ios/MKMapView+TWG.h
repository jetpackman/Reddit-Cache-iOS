//
//  MKMapView+TWG.h
//  Nitro
//
//  Created by Jeremy Bower on 12-02-09.
//  Copyright (c) 2012 Power Home Remodelling Group. All rights reserved.
//

#ifdef MK_CLASS_AVAILABLE

#import <MapKit/MapKit.h>
@interface MKMapView (TWG)

- (MKCoordinateRegion)regionThatFitsAnnotationsWithMinimumRadius:(CLLocationDistance)minimumRadius;

@end

#endif