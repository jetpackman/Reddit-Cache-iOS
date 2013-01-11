//
//  OnethingClientApi.m
//  onething
//
//  Created by Dane Carr on 12-02-13.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import "OnethingClientAPI.h"
#import "MapKit/MapKit.h"
#import "CoreLocation/CoreLocation.h"
#import "OnethingConstants.h"

@interface OnethingClientAPI (private)

+ (User*)userFromJson:(NSDictionary*)jsonUser;
+ (NSArray*)gratitudesFromJson:(NSArray*)jsonGratitudes;
+ (Gratitude*)gratitudeFromJson:(NSDictionary*)jsonGratitude;
+ (NSArray*)gratitudeBinsFromJson:(NSArray*)binsArray;
+ (GratitudeBin*)myGratitudeBinFromJson:(NSDictionary*)binDict;
+ (GratitudeBin*)othersGratitudeBinFromJson:(NSDictionary*)binDict;
+ (NSInteger)priorityForAddressType:(NSString*)addressType;
+ (NSString*) formattedStringForAPICall:(NSString*)unescapedString;
+ (NSString*) escapedStringForAPICall:(NSString*)unescapedString;


@end

@implementation OnethingClientAPI

+ (NSString*) apiBaseURL {
    return OnethingProductionBaseURL;
//    return OnethingStagingBaseURL;
}

+ (OnethingClientAPI*)sharedClient {
    
    static OnethingClientAPI *_sharedClient = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedClient = [[OnethingClientAPI alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/api/v1/", [OnethingClientAPI apiBaseURL]]]];
    });
    
    return _sharedClient;
}

+ (NSInteger)priorityForAddressType:(NSString *)addressType {
    
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

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (self) {
        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
        [self setDefaultHeader:@"Accept" value:@"application/json"];
    }
    return self;
}

#pragma mark - Extended AFHTTPClient methods

- (AFHTTPRequestOperation*)HTTPRequestOperationWithRequest:(NSURLRequest *) request 
                                                   startup:(OnethingClientAPIStartupBlock)startup 
                                                   success:(void (^)(AFHTTPRequestOperation *, id))success 
                                                   failure:(void (^)(AFHTTPRequestOperation*, NSError *))failure 
                                                completion:(OnethingClientAPICompletionBlock)completion {
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
     completion:(OnethingClientAPICompletionBlock)completion {
    
    NSMutableURLRequest* request = [self requestWithMethod:@"GET" path:path parameters:parameters];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    
    AFHTTPRequestOperation* operation = [self HTTPRequestOperationWithRequest:request startup:startup success:success failure:failure completion:completion];
    [self enqueueHTTPRequestOperation:operation];
}

- (void)postPath:(NSString *)path parameters:(NSDictionary *)parameters startup:(OnethingClientAPIStartupBlock)startup success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure completion:(OnethingClientAPICompletionBlock)completion {
    
    NSMutableURLRequest* request = [self requestWithMethod:@"POST" path:path parameters:parameters];
    AFHTTPRequestOperation* operation = [self HTTPRequestOperationWithRequest:request startup:startup success:success failure:failure completion:completion];
    [self enqueueHTTPRequestOperation:operation];
}

- (void)putPath:(NSString *)path parameters:(NSDictionary *)parameters startup:(OnethingClientAPIStartupBlock)startup success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure completion:(OnethingClientAPICompletionBlock)completion {
    
    NSMutableURLRequest* request = [self requestWithMethod:@"PUT" path:path parameters:parameters];
    AFHTTPRequestOperation* operation = [self HTTPRequestOperationWithRequest:request startup:startup success:success failure:failure completion:completion];
    [self enqueueHTTPRequestOperation:operation];
}

- (void)deletePath:(NSString *)path parameters:(NSDictionary *)parameters startup:(OnethingClientAPIStartupBlock)startup success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure completion:(OnethingClientAPICompletionBlock)completion {
    
    NSMutableURLRequest* request = [self requestWithMethod:@"DELETE" path:path parameters:parameters];
    AFHTTPRequestOperation* operation = [self HTTPRequestOperationWithRequest:request startup:startup success:success failure:failure completion:completion];
    [self enqueueHTTPRequestOperation:operation];
}

#pragma mark - Login

- (void)loginWithUsername:(NSString *)username 
                 password:(NSString *)password
                  startup:(OnethingClientAPIStartupBlock)startup 
                  success:(OnethingClientAPILoginSuccessBlock)success 
                  failure:(OnethingClientAPIFailureBlock)failure 
               completion:(OnethingClientAPICompletionBlock)completion {
    
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:[OnethingClientAPI formattedStringForAPICall:username], @"email", [OnethingClientAPI formattedStringForAPICall:password], @"password", nil];
    [self postPath:@"login"
        parameters:params
           startup:startup 
           success:^(AFHTTPRequestOperation *operation, id responseObject) {
               if (success) {
                   User* user = [OnethingClientAPI userFromJson:responseObject];
                   user.registeredUser = YES;
                   success(user);
               }
           } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
               if (failure) {
                   failure(operation.response, error);
               }
           } completion:completion];
}

- (void)renewLoginWithKey:(NSString *)key 
                  startup:(OnethingClientAPIStartupBlock)startup 
                  success:(OnethingClientAPILoginSuccessBlock)success 
                  failure:(OnethingClientAPIFailureBlock)failure 
               completion:(OnethingClientAPICompletionBlock)completion {
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:key, @"api_key", nil];
    
    [self getPath:@"user" 
       parameters:params 
          startup:startup 
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              User *user = [OnethingClientAPI userFromJson:responseObject];
              user.registeredUser = YES;
              success(user);
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              if (failure) {
                  failure(operation.response, error);
              }
          } completion:completion];
}

#pragma mark - User
- (void)updateUserWithName:(NSString*)name 
                  password:(NSString*)password 
                     email:(NSString*)email
                    apiKey:(NSString*)apiKey
        receivesNewsletter:(NSString*)receivesNewsLetter
                   startup:(OnethingClientAPIStartupBlock)startup 
                   success:(OnethingClientAPILoginSuccessBlock)success 
                   failure:(OnethingClientAPIFailureBlock)failure 
                completion:(OnethingClientAPICompletionBlock)completion {
    
    NSDictionary* params;
    if (password != nil) {
        params = [NSDictionary dictionaryWithObjectsAndKeys:
                  [OnethingClientAPI formattedStringForAPICall:name], @"user[name]",
                  [OnethingClientAPI formattedStringForAPICall:password], @"user[password]",
                  [OnethingClientAPI formattedStringForAPICall:email], @"user[email]",
                  [OnethingClientAPI formattedStringForAPICall:receivesNewsLetter], @"user[receive_newsletter]",
                  apiKey, @"api_key",
                  nil];
    } else {
        params = [NSDictionary dictionaryWithObjectsAndKeys:
                  [OnethingClientAPI formattedStringForAPICall:name], @"user[name]",
                  [OnethingClientAPI formattedStringForAPICall:email], @"user[email]",
                  [OnethingClientAPI formattedStringForAPICall:receivesNewsLetter], @"user[receive_newsletter]",
                  apiKey, @"api_key",
                  nil];
    }
    
    [self putPath:@"user"
       parameters:params
          startup:startup
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              if (success) {
                  User *user = [OnethingClientAPI userFromJson:responseObject];
                  user.registeredUser = YES;
                  success(user);              }
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              if (failure) {
                  failure(operation.response, error);
              }
          } completion:completion];
}

#pragma mark - Signup

- (void)signupUserWithName:(NSString*)name
                  username:(NSString*)username
                  password:(NSString*)password
                  feedback:(NSString*)feedback
                   startup:(OnethingClientAPIStartupBlock)startup
                   success:(OnethingClientAPISignupSuccessBlock)success
                   failure:(OnethingClientAPIFailureBlock)failure
                completion:(OnethingClientAPICompletionBlock)completion {
    
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:[OnethingClientAPI formattedStringForAPICall:name], @"user[name]", [OnethingClientAPI formattedStringForAPICall:username], @"user[email]", [OnethingClientAPI formattedStringForAPICall:password], @"user[password]", [OnethingClientAPI formattedStringForAPICall:feedback], @"user[feedback]", nil];
    [self postPath:@"user"
        parameters:params
           startup:startup 
           success:^(AFHTTPRequestOperation *operation, id responseObject) {
               if (success) {
                   User* user = [OnethingClientAPI userFromJson:responseObject];
                   user.registeredUser = YES;
                   success(user);
               }
           } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
               if (failure) {
                   failure(operation.response, error);
               }
           } completion:completion];
}

- (void)resetPasswordWithEmail:(NSString*)email
                       startup:(OnethingClientAPIStartupBlock)startup
                       success:(OnethingClientAPISuccessBlock)success
                       failure:(OnethingClientAPIFailureBlock)failure
                    completion:(OnethingClientAPICompletionBlock)completion
{
    NSDictionary *params = [NSDictionary dictionaryWithObject:email forKey:@"user[email]"];
    
    [self postPath:@"password"
       parameters:params
          startup:startup
          success:^(AFHTTPRequestOperation *operation, id JSON) {
              if (success) {
                  success(JSON);
              }
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              if (failure) {
                  failure(operation.response, error);
              }
          } completion:completion];
}

#pragma mark - My Gratitude

- (void)gratitudesWithParameters:(NSDictionary *)parameters 
                         startup:(OnethingClientAPIStartupBlock)startup 
                         success:(OnethingClientAPIGratitudesSuccessBlock)success 
                         failure:(OnethingClientAPIFailureBlock)failure 
                      completion:(OnethingClientAPICompletionBlock)completion {   
    
    [self getPath:@"things" 
       parameters:parameters 
          startup:startup 
          success:^(AFHTTPRequestOperation *operation, id JSON) {
              NSArray *jsonGratitudes = [JSON objectForKey:@"things"];
              int count = [[JSON objectForKey:@"count"] intValue];
              if (success) {
                  success([OnethingClientAPI gratitudesFromJson:jsonGratitudes],count);
              }
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              if (failure) {
                  failure(operation.response, error);
              }
          } completion:completion];
}

- (void)gratitudesWithApiKey:(NSString *)apiKey 
                    anchorId:(NSInteger)anchorId
                     perPage:(NSInteger)perPage 
                     startup:(OnethingClientAPIStartupBlock)startup 
                     success:(OnethingClientAPIGratitudesSuccessBlock)success 
                     failure:(OnethingClientAPIFailureBlock)failure 
                  completion:(OnethingClientAPICompletionBlock)completion {
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:@"true", @"private", [NSNumber numberWithInteger:perPage], @"per_page", [NSNumber numberWithInteger:anchorId], @"anchor_id", apiKey, @"api_key", nil];
    [self gratitudesWithParameters:parameters 
                           startup:startup 
                           success:success 
                           failure:failure 
                        completion:completion];
}

- (void)gratitudesWithApiKey:(NSString *)apiKey 
                     perPage:(NSInteger)perPage 
                     startup:(OnethingClientAPIStartupBlock)startup 
                     success:(OnethingClientAPIGratitudesSuccessBlock)success 
                     failure:(OnethingClientAPIFailureBlock)failure 
                  completion:(OnethingClientAPICompletionBlock)completion {
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:@"true", @"private", [NSNumber numberWithInteger:perPage], @"per_page", apiKey, @"api_key", nil];
    [self gratitudesWithParameters:parameters 
                           startup:startup 
                           success:success 
                           failure:failure 
                        completion:completion];
}

- (void)gratitudesForDate:(NSString *)date 
                   apiKey:(NSString *)apiKey 
                 anchorId:(NSInteger)anchorId 
                  perPage:(NSInteger)perPage 
                  startup:(OnethingClientAPIStartupBlock)startup 
                  success:(OnethingClientAPIGratitudesSuccessBlock)success 
                  failure:(OnethingClientAPIFailureBlock)failure 
               completion:(OnethingClientAPICompletionBlock)completion {
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:apiKey, @"api_key", date, @"date", @"true", @"private", [NSNumber numberWithInteger:anchorId], @"anchor_id", [NSNumber numberWithInteger:perPage], @"per_page", nil];
    [self gratitudesWithParameters:parameters 
                           startup:startup 
                           success:success 
                           failure:failure 
                        completion:completion];
}

- (void)gratitudesForDate:(NSString *)date 
                   apiKey:(NSString *)apiKey 
                  perPage:(NSInteger)perPage 
                  startup:(OnethingClientAPIStartupBlock)startup 
                  success:(OnethingClientAPIGratitudesSuccessBlock)success 
                  failure:(OnethingClientAPIFailureBlock)failure 
               completion:(OnethingClientAPICompletionBlock)completion {
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:apiKey, @"api_key", date, @"date", @"true", @"private", [NSNumber numberWithInteger:perPage], @"per_page", nil];
    [self gratitudesWithParameters:parameters 
                           startup:startup 
                           success:success 
                           failure:failure 
                        completion:completion];
}

- (void)gratitudesForTopWord:(NSString *)word 
                      apiKey:(NSString *)apiKey 
                    anchorId:(NSInteger)anchorId 
                     perPage:(NSInteger)perPage 
                     startup:(OnethingClientAPIStartupBlock)startup 
                     success:(OnethingClientAPIGratitudesSuccessBlock)success 
                     failure:(OnethingClientAPIFailureBlock)failure 
                  completion:(OnethingClientAPICompletionBlock)completion {
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:apiKey, @"api_key", @"true", @"private", word, @"word", [NSNumber numberWithInteger:anchorId], @"anchor_id", [NSNumber numberWithInteger:perPage], @"per_page", nil];
    [self gratitudesWithParameters:parameters 
                           startup:startup 
                           success:success 
                           failure:failure 
                        completion:completion];
}

- (void)gratitudesForTopWord:(NSString *)word 
                      apiKey:(NSString *)apiKey 
                     perPage:(NSInteger)perPage 
                     startup:(OnethingClientAPIStartupBlock)startup 
                     success:(OnethingClientAPIGratitudesSuccessBlock)success 
                     failure:(OnethingClientAPIFailureBlock)failure 
                  completion:(OnethingClientAPICompletionBlock)completion {
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:apiKey, @"api_key", @"true", @"private", word, @"word", [NSNumber numberWithInteger:perPage], @"per_page", nil];
    [self gratitudesWithParameters:parameters 
                           startup:startup 
                           success:success 
                           failure:failure 
                        completion:completion];
}
    
- (void)randomGratitudesWithApiKey:(NSString *)apiKey 
                           perPage:(NSInteger)perPage 
                           startup:(OnethingClientAPIStartupBlock)startup 
                           success:(OnethingClientAPIGratitudesSuccessBlock)success 
                           failure:(OnethingClientAPIFailureBlock)failure 
                        completion:(OnethingClientAPICompletionBlock)completion {
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:apiKey, @"api_key", @"true", @"random", @"true", @"private", [NSNumber numberWithInteger:perPage], @"per_page", nil];
    [self gratitudesWithParameters:parameters 
                           startup:startup 
                           success:success 
                           failure:failure 
                        completion:completion];
}

- (void)publicGratitudesWithApiKey:(NSString *)apiKey 
                          anchorId:(NSInteger)anchorId 
                           perPage:(NSInteger)perPage 
                           startup:(OnethingClientAPIStartupBlock)startup 
                           success:(OnethingClientAPIGratitudesSuccessBlock)success 
                           failure:(OnethingClientAPIFailureBlock)failure 
                        completion:(OnethingClientAPICompletionBlock)completion {
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:apiKey, @"api_key", @"false", @"private", [NSNumber numberWithInteger:anchorId], @"anchor_id", [NSNumber numberWithInteger:perPage], @"per_page", nil];
    [self gratitudesWithParameters:parameters 
                                 startup:startup 
                                 success:success 
                                 failure:failure 
                              completion:completion];
}

- (void)publicGratitudesWithApiKey:(NSString *)apiKey 
                           perPage:(NSInteger)perPage 
                           startup:(OnethingClientAPIStartupBlock)startup 
                           success:(OnethingClientAPIGratitudesSuccessBlock)success 
                           failure:(OnethingClientAPIFailureBlock)failure 
                        completion:(OnethingClientAPICompletionBlock)completion {
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:apiKey, @"api_key", @"false", @"private", [NSNumber numberWithInteger:perPage], @"per_page", nil];
    [self gratitudesWithParameters:parameters 
                           startup:startup 
                           success:success 
                           failure:failure 
                        completion:completion];
}

- (void)createGratitudeWithBody:(NSString *)body 
                         apiKey:(NSString*)apiKey
                        startup:(OnethingClientAPIStartupBlock)startup
                        success:(OnethingClientAPICreateGratitudeSuccessBlock)success
                        failure:(OnethingClientAPIFailureBlock)failure
                     completion:(OnethingClientAPICompletionBlock)completion {
    
    [self createGratitudeWithBody:body apiKey:apiKey location:nil neighbourhood:nil city:nil startup:startup success:success failure:failure completion:completion];
}

- (void)createGratitudeWithBody:(NSString *)body 
                         apiKey:(NSString *)apiKey
                       location:(CLLocation*)location 
                  neighbourhood:(NSString*)neighbourhood
                           city:(NSString*)city
                        startup:(OnethingClientAPIStartupBlock)startup
                        success:(OnethingClientAPICreateGratitudeSuccessBlock)success 
                        failure:(OnethingClientAPIFailureBlock)failure 
                     completion:(OnethingClientAPICompletionBlock)completion {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:[OnethingClientAPI formattedStringForAPICall:body], @"thing[body]", apiKey, @"api_key", nil];
    if (location) {
        [params setObject:[NSString stringWithFormat:@"%f", location.coordinate.latitude] forKey:@"thing[lat]"];
        [params setObject:[NSString stringWithFormat:@"%f", location.coordinate.longitude] forKey:@"thing[lng]"];
        if (neighbourhood) {
            [params setObject:neighbourhood forKey:@"thing[neighbourhood]"];
        }
        if (city) {
            [params setObject:city forKey:@"thing[city]"];
        }
    }
    NSDate *today = [NSDate date];
    static NSDateFormatter *dateFormatter;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    }
    [params setObject:[NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:today]] forKey:@"thing[posted_for]"];
    
    [self postPath:@"things"
        parameters:params 
           startup:startup 
           success:^(AFHTTPRequestOperation *operation, id JSON) {
               if (success) {
                   success([OnethingClientAPI gratitudeFromJson:JSON]);
               }
           } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
               if (failure) {
                   failure(operation.response, error);
               }
           } completion:completion];
}

- (void)editGratitude:(Gratitude *)gratitude 
               apiKey:(NSString *)apiKey 
              startup:(OnethingClientAPIStartupBlock)startup
              success:(OnethingClientAPICreateGratitudeSuccessBlock)success 
              failure:(OnethingClientAPIFailureBlock)failure 
           completion:(OnethingClientAPICompletionBlock)completion {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:[OnethingClientAPI formattedStringForAPICall:gratitude.body], @"thing[body]", apiKey, @"api_key", nil];
    if (CLLocationCoordinate2DIsValid(gratitude.location)) {
        [params setObject:[NSString stringWithFormat:@"%f", gratitude.location.latitude] forKey:@"thing[lat]"];
        [params setObject:[NSString stringWithFormat:@"%f", gratitude.location.longitude] forKey:@"thing[lng]"];
        if (gratitude.neighbourhood) {
            [params setObject:gratitude.neighbourhood forKey:@"thing[neighbourhood]"];
        }
        if (gratitude.city) {
            [params setObject:gratitude.city forKey:@"thing[city]"];
        } 
    }

    [self putPath:[NSString stringWithFormat:@"things/%@", gratitude.gratitudeId]
        parameters:params 
           startup:startup 
           success:^(AFHTTPRequestOperation *operation, id JSON) {
               if (success) {
                   success([OnethingClientAPI gratitudeFromJson:JSON]);
               }
           } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
               if (failure) {
                   failure(operation.response, error);
               }
           } completion:completion];
}

- (void)publishGratitude:(Gratitude *)gratitude 
                apiKey:(NSString *)apiKey 
               startup:(OnethingClientAPIStartupBlock)startup 
               success:(OnethingClientAPICreateGratitudeSuccessBlock)success 
               failure:(OnethingClientAPIFailureBlock)failure 
            completion:(OnethingClientAPICompletionBlock)completion {
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys: apiKey, @"api_key", nil];
    [self putPath:[NSString stringWithFormat:@"things/%@/publish", gratitude.gratitudeId] 
       parameters:params 
          startup:startup 
          success:^(AFHTTPRequestOperation *operation, id JSON) {
              if (success) {
                  success([OnethingClientAPI gratitudeFromJson:JSON]);
              }
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              if (failure) {
                  failure(operation.response, error);
              }        
          } completion:completion];
}

- (void)shareGratitude:(Gratitude *)gratitude 
                  apiKey:(NSString *)apiKey 
                 startup:(OnethingClientAPIStartupBlock)startup 
                 success:(OnethingClientAPICreateGratitudeSuccessBlock)success 
                 failure:(OnethingClientAPIFailureBlock)failure 
              completion:(OnethingClientAPICompletionBlock)completion {
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys: apiKey, @"api_key", nil];
    [self putPath:[NSString stringWithFormat:@"things/%@/share", gratitude.gratitudeId] 
       parameters:params 
          startup:startup 
          success:^(AFHTTPRequestOperation *operation, id JSON) {
              if (success) {
                  success([OnethingClientAPI gratitudeFromJson:JSON]);
              }
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              if (failure) {
                  failure(operation.response, error);
              }        
          } completion:completion];
}

- (void)likeGratitude:(Gratitude*)gratitude 
               apiKey:(NSString*)apiKey 
             duration:(NSTimeInterval)duration
              startup:(OnethingClientAPIStartupBlock)startup 
              success:(OnethingClientAPISuccessBlock)success 
              failure:(OnethingClientAPIFailureBlock)failure 
           completion:(OnethingClientAPICompletionBlock)completion {
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys: apiKey, @"api_key", [NSNumber numberWithDouble:duration], @"duration", nil];
    [self putPath:[NSString stringWithFormat:@"things/%@/like", gratitude.gratitudeId]
        parameters:params 
           startup:startup 
          success:^(AFHTTPRequestOperation *operation, id JSON) {
              if (success) {
                  success([OnethingClientAPI gratitudeFromJson:JSON]);
              }
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
               if (failure) {
                   failure(operation.response, error);
               }        
          }
       completion:completion];
}

#pragma mark - Gratitudes (Map)
- (void)gratitudesForNeighbourhood:(NSString*)neighbourhood
                              city:(NSString*)city
                       apiKey:(NSString*)apiKey 
                     anchorId:(NSInteger)anchorId
                       isMine:(BOOL)isMine
                      perPage:(NSInteger)perPage
                      startup:(OnethingClientAPIStartupBlock)startup 
                      success:(OnethingClientAPIGratitudesSuccessBlock)success 
                      failure:(OnethingClientAPIFailureBlock)failure 
                   completion:(OnethingClientAPICompletionBlock)completion {
    NSString* private = isMine ? @"true" : @"false";
    NSString* is_mine = isMine ? @"true" : @"false";

    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:apiKey, @"api_key", private, @"private", is_mine, @"is_mine",  neighbourhood, @"neighbourhood", city, @"city", [NSNumber numberWithInteger:anchorId], @"anchor_id", [NSNumber numberWithInteger:perPage], @"per_page", nil];
    [self getPath:@"things" 
       parameters:parameters 
          startup:startup
          success:^(AFHTTPRequestOperation *operation, id JSON) {
              NSArray *jsonGratitudes = [[JSON objectForKey:@"things"] nilForNull];
              int count = [[JSON objectForKey:@"count"] intValue];
              if (success) {
                  success([OnethingClientAPI gratitudesFromJson:jsonGratitudes], count);
              }
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              if (failure) {
                  failure(operation.response, error);
              }
          } completion:completion];
}

- (void)gratitudesForNeighbourhood:(NSString*)neighbourhood
                              city:(NSString*)city
                            apiKey:(NSString*)apiKey 
                            isMine:(BOOL)isMine
                           perPage:(NSInteger)perPage
                           startup:(OnethingClientAPIStartupBlock)startup 
                           success:(OnethingClientAPIGratitudesSuccessBlock)success 
                           failure:(OnethingClientAPIFailureBlock)failure 
                        completion:(OnethingClientAPICompletionBlock)completion {
    NSString* private = isMine ? @"true" : @"false";
    NSString* is_mine = isMine ? @"true" : @"false";

    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:apiKey, @"api_key", private, @"private", is_mine, @"is_mine",  neighbourhood, @"neighbourhood", city, @"city", [NSNumber numberWithInteger:perPage], @"per_page", nil];
    [self getPath:@"things" 
       parameters:parameters 
          startup:startup
          success:^(AFHTTPRequestOperation *operation, id JSON) {
              NSArray *jsonGratitudes = [[JSON objectForKey:@"things"] nilForNull];
              int count = [[JSON objectForKey:@"count"] intValue];
              if (success) {
                  success([OnethingClientAPI gratitudesFromJson:jsonGratitudes], count);
              }
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              if (failure) {
                  failure(operation.response, error);
              }
          } completion:completion];
}

- (void)gratitudeMapForLocation:(CLLocationCoordinate2D)location
                         apiKey:(NSString*)apiKey 
                        startup:(OnethingClientAPIStartupBlock)startup 
                        success:(OnethingClientAPIGratitudeBinsSuccessBlock)success 
                        failure:(OnethingClientAPIFailureBlock)failure 
                     completion:(OnethingClientAPICompletionBlock)completion {
    
    [self getPath:@"locations" 
       parameters:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%f",location.latitude], @"lat", [NSString stringWithFormat:@"%f",location.longitude], @"lng", apiKey, @"api_key", nil]
          startup:startup
          success:^(AFHTTPRequestOperation *operation, id JSON) {
              if (success) {
                  success([OnethingClientAPI gratitudeBinsFromJson:JSON]);
              }
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              if (failure) {
                  failure(operation.response, error);
              }
          } completion:completion];
}

#pragma mark - Calendar
- (void)calendarIndexWithApiKey:(NSString*)apiKey 
                        fromDate:(NSDate*)fromDate
                         toDate:(NSDate*)toDate
                        startup:(OnethingClientAPIStartupBlock)startup 
                        success:(OnethingClientAPICalendarIndexSuccessBlock)success 
                        failure:(OnethingClientAPIFailureBlock)failure 
                     completion:(OnethingClientAPICompletionBlock)completion {
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:apiKey, @"api_key", fromDate, @"from_date", toDate, @"to_date", nil];
    [self getPath:@"calendar"
       parameters:params 
          startup:startup 
          success:^(AFHTTPRequestOperation *operation, id JSON) {
              if (success) {
                  success(JSON);
              }
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              if (failure) {
                  failure(operation.response, error);
              }
          } completion:completion];
}

#pragma mark - Top Words
- (void)topWordsWithApiKey:(NSString *)apiKey 
                  anchorId:(NSInteger)anchorId
                   startup:(OnethingClientAPIStartupBlock)startup 
                   success:(OnethingClientAPITopWordsSuccessBlock)success 
                   failure:(OnethingClientAPIFailureBlock)failure 
                completion:(OnethingClientAPICompletionBlock)completion {
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:apiKey, @"api_key", [NSNumber numberWithInteger:anchorId], @"anchor_id", nil];
    [self getPath:@"words" 
       parameters:params
          startup:startup
          success:^(AFHTTPRequestOperation *operation, id JSON) {
              if (success) {
                  success(JSON);
              }
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              if (failure) {
                  failure(operation.response, error);
              }
          } completion:completion];
}

- (void)topWordsWithApiKey:(NSString *)apiKey 
                   startup:(OnethingClientAPIStartupBlock)startup 
                   success:(OnethingClientAPITopWordsSuccessBlock)success 
                   failure:(OnethingClientAPIFailureBlock)failure 
                completion:(OnethingClientAPICompletionBlock)completion {
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:apiKey, @"api_key", nil];
    [self getPath:@"words" 
       parameters:params
          startup:startup
          success:^(AFHTTPRequestOperation *operation, id JSON) {
              if (success) {
                  success(JSON);
              }
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              if (failure) {
                  failure(operation.response, error);
              }
          } completion:completion];
    
}

- (void)removeTopWordWithApiKey:(NSString *)apiKey 
                         wordId:(NSString *)wordId
                        startup:(OnethingClientAPIStartupBlock)startup 
                        success:(OnethingClientAPIRemoveTopWordSuccessBlock)success 
                        failure:(OnethingClientAPIFailureBlock)failure 
                     completion:(OnethingClientAPICompletionBlock)completion {
    
    [self deletePath:[NSString stringWithFormat:@"words/%@", wordId] 
          parameters:[NSDictionary dictionaryWithObjectsAndKeys:apiKey, @"api_key", wordId, @"id", nil]
           startup:startup
           success:^(AFHTTPRequestOperation *operation, id JSON) {
               if (success) {
                   success(JSON);
               }
           } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
               if (failure) {
                   failure(operation.response, error);
               }
           } completion:completion];
}

#pragma mark - JSON

+ (User*)userFromJson: (NSDictionary *)jsonUser {
    User *user = [[User alloc] init];
    
    user.userId = [[jsonUser objectForKey:@"id"] nilForNull];
    user.name = [[jsonUser objectForKey:@"name"] nilForNull];
    user.email = [[jsonUser objectForKey:@"email"] nilForNull];
    user.apiKey = [[jsonUser objectForKey:@"api_key"] nilForNull];
    user.registeredUser = NO;
    user.receivesNewsletter = [[jsonUser objectForKey:@"receive_newsletter"] stringValue];
    
    return user;
}

+ (NSArray*)gratitudesFromJson:(NSArray*)jsonGratitudes {
    NSMutableArray* gratitudes = [NSMutableArray arrayWithCapacity:jsonGratitudes.count];
    for (NSDictionary *jsonGratitude in jsonGratitudes) {
        [gratitudes addObject:[OnethingClientAPI gratitudeFromJson:jsonGratitude]];
    }
    return gratitudes;
}

+ (Gratitude*)gratitudeFromJson:(NSDictionary *)jsonGratitude {
    Gratitude *gratitude = [[Gratitude alloc] init];
    gratitude.gratitudeId = [[[jsonGratitude objectForKey:@"id"] stringValue] nilForNull];
    gratitude.isMine = [[[jsonGratitude objectForKey:@"is_mine"] nilForNull] boolValue];
    gratitude.isPublic =  [[[jsonGratitude objectForKey:@"public"] nilForNull] boolValue];
    gratitude.body = [[jsonGratitude objectForKey:@"body"] nilForNull];
    NSString* dateString = [[jsonGratitude objectForKey:@"created_at"] nilForNull];
    if (dateString) {
        gratitude.createdAt = [NSDateFormatter dateFromString:dateString];
    } else {
        gratitude.createdAt = [NSDate date];
    }
    gratitude.liked = [[[jsonGratitude objectForKey:@"liked"] nilForNull] boolValue];
    gratitude.likeCount = [[[jsonGratitude objectForKey:@"liked_things_count"] nilForNull] integerValue];
    if ([[jsonGratitude objectForKey:@"lat"] nilForNull] && [[jsonGratitude objectForKey:@"lng"] nilForNull]) {
        CLLocationDegrees lat = [[jsonGratitude objectForKey:@"lat"] doubleValue];
        CLLocationDegrees lng = [[jsonGratitude objectForKey:@"lng"] doubleValue];
        gratitude.location = CLLocationCoordinate2DMake(lat, lng);
        gratitude.hasLocation = YES;
        gratitude.neighbourhood = [[jsonGratitude objectForKey:@"neighbourhood"] nilForNull];
        gratitude.city = [[jsonGratitude objectForKey:@"city"] nilForNull];
    } else {
        gratitude.hasLocation = NO;
    }
    
    gratitude.likedTime = [[jsonGratitude objectForKey:@"liked_time"] nilForNull];
    return gratitude;
}

+ (NSArray*)gratitudeBinsFromJson:(NSArray *)binsArray {
    NSMutableArray* gratitudeBins = [NSMutableArray array];
    GratitudeBin* bin;
    for (NSMutableDictionary* binDict in binsArray){
        bin = [OnethingClientAPI myGratitudeBinFromJson:binDict];
        if(bin.gratCount > 0) {
            [gratitudeBins addObject:bin];
        }
        bin = [OnethingClientAPI othersGratitudeBinFromJson:binDict];
        if(bin.gratCount > 0) {
            [gratitudeBins addObject:bin];
        }

    }
    return gratitudeBins;
}

+ (GratitudeBin*)othersGratitudeBinFromJson:(NSDictionary *)binDict {
    GratitudeBin* otherBin = [[GratitudeBin alloc] init];
    otherBin.neighbourhood = [[binDict objectForKey:@"neighbourhood"] nilForNull];
    otherBin.city = [[binDict objectForKey:@"city"] nilForNull];
    CLLocationDegrees lat = [[binDict objectForKey:@"lat"] doubleValue];
    CLLocationDegrees lng = [[binDict objectForKey:@"lng"] doubleValue];
    otherBin.gratCount = [[binDict valueForKey:@"others_count"] intValue];
    otherBin.publicGratCount = [[binDict valueForKey:@"others_public_count"] intValue];
    otherBin.mine = false;
    otherBin.gratitudeType = OthersGratitudeAnnotationType;
    otherBin.coordinate = CLLocationCoordinate2DMake(lat, lng);
    return otherBin;
}

+ (GratitudeBin*)myGratitudeBinFromJson:(NSDictionary *)binDict {
    GratitudeBin* myBin = [[GratitudeBin alloc] init];
    myBin.neighbourhood = [[binDict objectForKey:@"neighbourhood"] nilForNull];
    myBin.city = [[binDict objectForKey:@"city"] nilForNull];;
    CLLocationDegrees lat = [[binDict objectForKey:@"lat"] doubleValue];
    CLLocationDegrees lng = [[binDict objectForKey:@"lng"] doubleValue];
    myBin.gratCount = [[binDict valueForKey:@"my_count"] intValue];
    myBin.publicGratCount = [[binDict valueForKey:@"my_public_count"] intValue];
    myBin.mine = true;
    myBin.gratitudeType = MyGratitudeAnnotationType;
    lat += MAX((((float)myBin.publicGratCount+1)/((float)myBin.gratCount+1))/1000, 0.01);
    lng -= MAX((((float)myBin.gratCount+1)/((float)myBin.publicGratCount+1))/1000, 0.01);
    myBin.coordinate = CLLocationCoordinate2DMake(lat, lng);
    return myBin;    
}


+ (NSString*) formattedStringForAPICall:(NSString*)body {
    body = [OnethingClientAPI escapedStringForAPICall:body];
    body = [body stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    body = [body stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    body = [body stringByReplacingOccurrencesOfString:@"\r" withString:@" "];
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@" +" options:NSRegularExpressionCaseInsensitive error:&error];
    body = [regex stringByReplacingMatchesInString:body options:0 range:NSMakeRange(0, [body length]) withTemplate:@" "];
    
    NSData *data = [body dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    body = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    return body;
}

+ (NSString*) escapedStringForAPICall:(NSString*)unescapedString {
    return [unescapedString stringByReplacingOccurrencesOfString:@"%" withString:@"%25"];
}

@end
