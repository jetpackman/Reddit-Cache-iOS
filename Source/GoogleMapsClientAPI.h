//
//  GoogleMapsClientAPI.h
//  onething
//
//  Created by Anthony Wong on 12-05-07.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import "AFHTTPClient.h"

@interface GoogleMapsClientAPI : AFHTTPClient
#pragma mark = Google Geocoding

typedef void(^OnethingClientAPIGeocodeSuccessBlock)(NSString *location, NSString *city);
+ (GoogleMapsClientAPI*)sharedClient;
- (void)neighbourhoodForLocation:(CLLocation*)location 
                         startup:(OnethingClientAPIStartupBlock)startup 
                         success:(OnethingClientAPIGeocodeSuccessBlock)success 
                         failure:(OnethingClientAPIFailureBlock)failure 
                      completion:(OnethingClientAPICompletionBlock)completion;

@end
