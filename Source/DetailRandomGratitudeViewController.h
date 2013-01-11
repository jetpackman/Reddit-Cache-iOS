//
//  DetailRandomGratitudeViewController.h
//  onething
//
//  Created by Chris Taylor on 12-06-28.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import "BaseGratitudeListViewController.h"

@interface DetailRandomGratitudeViewController : BaseGratitudeListViewController

@property (nonatomic, strong) Gratitude* gratitude;

- (void) configureWithGratitude:(Gratitude*)gratitude;

@end
