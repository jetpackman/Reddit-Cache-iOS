//
//  GoogleMapsClientAPI.m
//  onething
//
//  Created by Anthony Wong on 12-05-07.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import "GoogleMapsClientAPI.h"

@implementation GoogleMapsClientAPI

+ (GoogleMapsClientAPI*)sharedClient
{
    static GoogleMapsClientAPI *_sharedClient = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedClient = [[GoogleMapsClientAPI alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/api/v1/", [OnethingClientAPI apiBaseURL]]]];
    });
    
    return _sharedClient;
}

#pragma mark - Extended AFHTTPClient methods

- (AFHTTPRequestOperation*)HTTPRequestOperationWithRequest:(NSURLRequest *) request 
                                                   startup:(OnethingClientAPIStartupBlock)startup 
                                                   success:(void (^)(AFHTTPRequestOperation *, id))success 
                                                   failure:(void (^)(AFHTTPRequestOperation*, NSError *))failure 
                                                completion:(OnethingClientAPICompletionBlock)completion 
{
    // Create the operation.
    AFHTTPRequestOperation* operation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success || completion) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                if (success) {
                    success(operation, responseObject);
                }
                
                if (completion) {
                    completion();
                }
            }];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure || completion) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                if (failure) {
                    failure(operation, error);
                }
                
                if (completion) {
                    completion();
                }
            }];
        }
    }];
    
    // Call the startup
    if (startup) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            startup(operation);
        }];
    }
    
    return operation;
}

- (void)getPath:(NSString *)path 
     parameters:(NSDictionary *)parameters 
        startup:(OnethingClientAPIStartupBlock)startup 
        success:(void (^)(AFHTTPRequestOperation *, id))success 
        failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure 
     completion:(OnethingClientAPICompletionBlock)completion
{
    NSMutableURLRequest* request = [self requestWithMethod:@"GET" path:path parameters:parameters];
    AFHTTPRequestOperation* operation = [self HTTPRequestOperationWithRequest:request startup:startup success:success failure:failure completion:completion];
    [self enqueueHTTPRequestOperation:operation];
}

- (void)postPath:(NSString *)path parameters:(NSDictionary *)parameters startup:(OnethingClientAPIStartupBlock)startup success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure completion:(OnethingClientAPICompletionBlock)completion
{
    NSMutableURLRequest* request = [self requestWithMethod:@"POST" path:path parameters:parameters];
    AFHTTPRequestOperation* operation = [self HTTPRequestOperationWithRequest:request startup:startup success:success failure:failure completion:completion];
    [self enqueueHTTPRequestOperation:operation];
}

- (void)putPath:(NSString *)path parameters:(NSDictionary *)parameters startup:(OnethingClientAPIStartupBlock)startup success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure completion:(OnethingClientAPICompletionBlock)completion
{
    NSMutableURLRequest* request = [self requestWithMethod:@"PUT" path:path parameters:parameters];
    AFHTTPRequestOperation* operation = [self HTTPRequestOperationWithRequest:request startup:startup success:success failure:failure completion:completion];
    [self enqueueHTTPRequestOperation:operation];
}

- (void)deletePath:(NSString *)path parameters:(NSDictionary *)parameters startup:(OnethingClientAPIStartupBlock)startup success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure completion:(OnethingClientAPICompletionBlock)completion
{
    NSMutableURLRequest* request = [self requestWithMethod:@"DELETE" path:path parameters:parameters];
    AFHTTPRequestOperation* operation = [self HTTPRequestOperationWithRequest:request startup:startup success:success failure:failure completion:completion];
    [self enqueueHTTPRequestOperation:operation];
}


+ (NSInteger)priorityForAddressType:(NSString *)addressType
{
    static NSDictionary *addressPriorities;
    if (!addressPriorities) {
        addressPriorities = [[NSDictionary alloc] initWithObjectsAndKeys:
                             /**[[NSNumber alloc] initWithInt:14], @"point_of_interest", 
                              [[NSNumber alloc] initWithInt:13], @"natural_feature", 
                              [[NSNumber alloc] initWithInt:12], @"airport", 
                              [[NSNumber alloc] initWithInt:11], @"park", 
                              [[NSNumber alloc] initWithInt:10], @"establishment",
                              [[NSNumber alloc] initWithInt:9], @"premise",
                              [[NSNumber alloc] initWithInt:8], @"intersection",**/ 
                             [[NSNumber alloc] initWithInt:6], @"colloquial_area",
                             [[NSNumber alloc] initWithInt:5], @"sublocality",
                             [[NSNumber alloc] initWithInt:7], @"neighborhood",
                             [[NSNumber alloc] initWithInt:4], @"locality",
                             [[NSNumber alloc] initWithInt:3], @"administrative_area_level_3",
                             [[NSNumber alloc] initWithInt:2], @"administrative_area_level_2",
                             [[NSNumber alloc] initWithInt:1], @"administrative_area_level_1",
                             nil];
    }
    return [[addressPriorities objectForKey:addressType] intValue];
}

- (id)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if (self) {
        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
        [self setDefaultHeader:@"Accept" value:@"application/json"];
    }
    
    return self;
}

- (void)neighbourhoodForLocation:(CLLocation *)location 
                         startup:(OnethingClientAPIStartupBlock)startup 
                         success:(OnethingClientAPIGeocodeSuccessBlock)success 
                         failure:(OnethingClientAPIFailureBlock)failure 
                      completion:(OnethingClientAPICompletionBlock)completion
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%f,%f", location.coordinate.latitude, location.coordinate.longitude], @"latlng", @"true", @"sensor", nil];
    [self getPath:@"http://maps.googleapis.com/maps/api/geocode/json" 
       parameters:params
          startup:startup 
          success:^(AFHTTPRequestOperation *operation, id JSON) 
     {
         if (success) {
             if (![[[JSON objectForKey:@"success"] nilForNull] isEqualToString:@"OK"]) {
                 success(@"Area unavailable", @"");
             }
             NSMutableString *bestMatch = [[NSMutableString alloc] init];
             NSInteger bestMatchValue = 0;
             NSMutableString *city = nil;
             
             for (NSDictionary *result in [JSON objectForKey:@"results"]) {
                 for (NSDictionary *addressComponent in [result objectForKey:@"address_components"]) {
                     for (NSString* type in [addressComponent objectForKey:@"types"]) {
                         if ([GoogleMapsClientAPI priorityForAddressType:type] >= bestMatchValue) {
                             bestMatchValue = [GoogleMapsClientAPI priorityForAddressType:type];
                             bestMatch = [addressComponent objectForKey:@"long_name"];
                         }
                         if ([type isEqualToString:@"administrative_area_level_2"] && !city) {
                             city = [[NSMutableString alloc] initWithString:[addressComponent objectForKey:@"long_name"]];
                         }
                     }
                 }
                 for (NSString* type in [result objectForKey:@"types"]) {
                     if ([type isEqualToString:@"neighborhood"]) {
                         success(bestMatch, city);
                         return;
                     }
                 }
             }
             
             success(bestMatch, city);
         }
     } 
          failure:^(AFHTTPRequestOperation *operation, NSError *error) 
     {
         if (failure) {
             failure(operation.response, error);
         }
     } 
       completion:completion];
}



@end
