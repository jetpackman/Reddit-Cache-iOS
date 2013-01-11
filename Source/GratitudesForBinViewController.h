//
//  GratitudesForBinViewController.h
//  onething
//
//  Created by Anthony Wong on 12-05-11.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import "BaseGratitudeListViewController.h"

@interface GratitudesForBinViewController : BaseGratitudeListViewController

@property (nonatomic, assign) NSInteger gratCount;
@property (nonatomic, assign) NSInteger publicGratCount;
@property (nonatomic, assign) BOOL mine;
@property (nonatomic, strong) NSString* neighbourhood;
@property (nonatomic, strong) NSString* city;
@property (nonatomic, strong) CLLocation* location;
@property (nonatomic, strong) NSMutableArray* gratitudes;

@end
