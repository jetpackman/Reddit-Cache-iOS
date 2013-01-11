//
//  OnethingClientApi.h
//  onething
//
//  Created by Dane Carr on 12-02-13.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import "AFHTTPClient.h"
#import "AFJSONRequestOperation.h"
#import "SBJsonParser.h"
#import "User.h"
#import "Gratitude.h"
#import "GratitudeBin.h"
typedef void(^OnethingClientAPIStartupBlock)(NSOperation* operation);
typedef void(^OnethingClientAPISuccessBlock) ();
typedef void(^OnethingClientAPICompletionBlock)();
typedef void(^OnethingClientAPIFailureBlock)(NSHTTPURLResponse *response, NSError *error);

@interface OnethingClientAPI : AFHTTPClient

+ (OnethingClientAPI*)sharedClient;
+ (NSString*) apiBaseURL;


#pragma mark - Login

typedef void(^OnethingClientAPILoginSuccessBlock)(id responseUser);

- (void)loginWithUsername:(NSString*)username
                 password:(NSString*)password
                 startup:(OnethingClientAPIStartupBlock)startup 
                 success:(OnethingClientAPILoginSuccessBlock)success 
                 failure:(OnethingClientAPIFailureBlock)failure 
              completion:(OnethingClientAPICompletionBlock)completion;

- (void)renewLoginWithKey:(NSString*)key 
                  startup:(OnethingClientAPIStartupBlock)startup 
                  success:(OnethingClientAPILoginSuccessBlock)success 
                  failure:(OnethingClientAPIFailureBlock)failure 
               completion:(OnethingClientAPICompletionBlock)completion;

#pragma mark - User

- (void)updateUserWithName:(NSString*)name
                      password:(NSString*)password
                         email:(NSString*)email
                        apiKey:(NSString*)apiKey
        receivesNewsletter:(NSString*)receivesNewsletter
                       startup:(OnethingClientAPIStartupBlock)startup 
                       success:(OnethingClientAPILoginSuccessBlock)success 
                       failure:(OnethingClientAPIFailureBlock)failure 
                    completion:(OnethingClientAPICompletionBlock)completion;

- (void)resetPasswordWithEmail:(NSString*)email
                       startup:(OnethingClientAPIStartupBlock)startup
                       success:(OnethingClientAPISuccessBlock)success
                       failure:(OnethingClientAPIFailureBlock)failure
                    completion:(OnethingClientAPICompletionBlock)completion;

#pragma mark - Signup

typedef void(^OnethingClientAPISignupSuccessBlock)(id responseUser);

- (void)signupUserWithName:(NSString*)name
                  username:(NSString*)username
                  password:(NSString*)password
                  feedback:(NSString*)feedback
                   startup:(OnethingClientAPIStartupBlock)startup
                   success:(OnethingClientAPISignupSuccessBlock)success
                   failure:(OnethingClientAPIFailureBlock)failure
                completion:(OnethingClientAPICompletionBlock)completion;


#pragma mark - Gratitudes

typedef void(^OnethingClientAPIGratitudesSuccessBlock)(NSArray *gratitudes, int count);

- (void)gratitudesWithParameters:(NSDictionary*)parameters 
                         startup:(OnethingClientAPIStartupBlock)startup 
                         success:(OnethingClientAPIGratitudesSuccessBlock)success 
                         failure:(OnethingClientAPIFailureBlock)failure 
                      completion:(OnethingClientAPICompletionBlock)completion;

- (void)gratitudesWithApiKey:(NSString*)apiKey 
                    anchorId:(NSInteger)anchorId 
                     perPage:(NSInteger)perPage 
                     startup:(OnethingClientAPIStartupBlock)startup 
                     success:(OnethingClientAPIGratitudesSuccessBlock)success 
                     failure:(OnethingClientAPIFailureBlock)failure 
                  completion:(OnethingClientAPICompletionBlock)completion;

- (void)gratitudesWithApiKey:(NSString*)apiKey 
                     perPage:(NSInteger)perPage 
                     startup:(OnethingClientAPIStartupBlock)startup 
                     success:(OnethingClientAPIGratitudesSuccessBlock)success 
                     failure:(OnethingClientAPIFailureBlock)failure 
                  completion:(OnethingClientAPICompletionBlock)completion;

- (void)randomGratitudesWithApiKey:(NSString*)apiKey 
                           perPage:(NSInteger)perPage 
                           startup:(OnethingClientAPIStartupBlock)startup 
                           success:(OnethingClientAPIGratitudesSuccessBlock)success 
                           failure:(OnethingClientAPIFailureBlock)failure 
                        completion:(OnethingClientAPICompletionBlock)completion;

- (void)publicGratitudesWithApiKey:(NSString*)apiKey 
                          anchorId:(NSInteger)anchorId 
                           perPage:(NSInteger)perPage 
                           startup:(OnethingClientAPIStartupBlock)startup 
                           success:(OnethingClientAPIGratitudesSuccessBlock)success 
                           failure:(OnethingClientAPIFailureBlock)failure 
                        completion:(OnethingClientAPICompletionBlock)completion;

- (void)publicGratitudesWithApiKey:(NSString*)apiKey 
                           perPage:(NSInteger)perPage 
                           startup:(OnethingClientAPIStartupBlock)startup 
                           success:(OnethingClientAPIGratitudesSuccessBlock)success 
                           failure:(OnethingClientAPIFailureBlock)failure 
                        completion:(OnethingClientAPICompletionBlock)completion;

typedef void(^OnethingClientAPICreateGratitudeSuccessBlock)(Gratitude* gratitude);

- (void)createGratitudeWithBody:(NSString*)body
                         apiKey:(NSString*)apiKey
                startup:(OnethingClientAPIStartupBlock)startup
                success:(OnethingClientAPICreateGratitudeSuccessBlock)success
                failure:(OnethingClientAPIFailureBlock)failure
             completion:(OnethingClientAPICompletionBlock)completion;

- (void)createGratitudeWithBody:(NSString*)body 
                         apiKey:(NSString*)apiKey 
                       location:(CLLocation*)location 
                  neighbourhood:(NSString*)neighbourhood
                           city:(NSString*)city
                        startup:(OnethingClientAPIStartupBlock)startup 
                        success:(OnethingClientAPICreateGratitudeSuccessBlock)success 
                        failure:(OnethingClientAPIFailureBlock)failure 
                     completion:(OnethingClientAPICompletionBlock)completion;

- (void)editGratitude:(Gratitude*)gratitude 
               apiKey:(NSString*)apiKey 
              startup:(OnethingClientAPIStartupBlock)startup 
              success:(OnethingClientAPICreateGratitudeSuccessBlock)success 
              failure:(OnethingClientAPIFailureBlock)failure 
           completion:(OnethingClientAPICompletionBlock)completion;


- (void)publishGratitude:(Gratitude*)gratitude 
                apiKey:(NSString*)apiKey 
               startup:(OnethingClientAPIStartupBlock)startup 
               success:(OnethingClientAPICreateGratitudeSuccessBlock)success 
               failure:(OnethingClientAPIFailureBlock)failure 
            completion:(OnethingClientAPICompletionBlock)completion;

- (void)shareGratitude:(Gratitude*)gratitude
                apiKey:(NSString*)apiKey
               startup:(OnethingClientAPIStartupBlock)startup
               success:(OnethingClientAPICreateGratitudeSuccessBlock)success 
               failure:(OnethingClientAPIFailureBlock)failure 
            completion:(OnethingClientAPICompletionBlock)completion;

- (void)likeGratitude:(Gratitude*)gratitude 
               apiKey:(NSString*)apiKey 
             duration:(NSTimeInterval)duration
              startup:(OnethingClientAPIStartupBlock)startup 
              success:(OnethingClientAPISuccessBlock)success 
              failure:(OnethingClientAPIFailureBlock)failure 
           completion:(OnethingClientAPICompletionBlock)completion;


#pragma mark - Calendar

typedef void(^OnethingClientAPICalendarIndexSuccessBlock)(NSArray *calendarIndex);

- (void)calendarIndexWithApiKey:(NSString*)apiKey 
                        fromDate:(NSDate*)fromDate
                         toDate:(NSDate*)toDate
                        startup:(OnethingClientAPIStartupBlock)startup 
                        success:(OnethingClientAPICalendarIndexSuccessBlock)success 
                        failure:(OnethingClientAPIFailureBlock)failure 
                     completion:(OnethingClientAPICompletionBlock)completion;

- (void)gratitudesForDate:(NSString*)date 
                   apiKey:(NSString*)apiKey 
                 anchorId:(NSInteger)anchorId 
                  perPage:(NSInteger)perPage
                  startup:(OnethingClientAPIStartupBlock)startup 
                  success:(OnethingClientAPIGratitudesSuccessBlock)success 
                  failure:(OnethingClientAPIFailureBlock)failure 
               completion:(OnethingClientAPICompletionBlock)completion;

- (void)gratitudesForDate:(NSString*)date 
                   apiKey:(NSString*)apiKey 
                  perPage:(NSInteger)perPage
                  startup:(OnethingClientAPIStartupBlock)startup 
                  success:(OnethingClientAPIGratitudesSuccessBlock)success 
                  failure:(OnethingClientAPIFailureBlock)failure 
               completion:(OnethingClientAPICompletionBlock)completion;

#pragma mark - Top Words

typedef void(^OnethingClientAPITopWordsSuccessBlock)(NSArray* topWords);

- (void)topWordsWithApiKey:(NSString *)apiKey 
                  anchorId:(NSInteger)anchorId
                   startup:(OnethingClientAPIStartupBlock)startup 
                   success:(OnethingClientAPITopWordsSuccessBlock)success 
                   failure:(OnethingClientAPIFailureBlock)failure 
                completion:(OnethingClientAPICompletionBlock)completion;

- (void)topWordsWithApiKey:(NSString *)apiKey 
                   startup:(OnethingClientAPIStartupBlock)startup 
                   success:(OnethingClientAPITopWordsSuccessBlock)success 
                   failure:(OnethingClientAPIFailureBlock)failure 
                completion:(OnethingClientAPICompletionBlock)completion;

typedef void(^OnethingClientAPIRemoveTopWordSuccessBlock)();

- (void)removeTopWordWithApiKey:(NSString *)apiKey 
                         wordId:(NSString *)wordId
                   startup:(OnethingClientAPIStartupBlock)startup 
                   success:(OnethingClientAPIRemoveTopWordSuccessBlock)success 
                   failure:(OnethingClientAPIFailureBlock)failure 
                completion:(OnethingClientAPICompletionBlock)completion;

- (void)gratitudesForTopWord:(NSString*)word 
                   apiKey:(NSString*)apiKey 
                 anchorId:(NSInteger)anchorId 
                  perPage:(NSInteger)perPage
                  startup:(OnethingClientAPIStartupBlock)startup 
                  success:(OnethingClientAPIGratitudesSuccessBlock)success 
                  failure:(OnethingClientAPIFailureBlock)failure 
               completion:(OnethingClientAPICompletionBlock)completion;

- (void)gratitudesForTopWord:(NSString*)word 
                      apiKey:(NSString*)apiKey 
                     perPage:(NSInteger)perPage
                     startup:(OnethingClientAPIStartupBlock)startup 
                     success:(OnethingClientAPIGratitudesSuccessBlock)success 
                     failure:(OnethingClientAPIFailureBlock)failure 
                  completion:(OnethingClientAPICompletionBlock)completion;

#pragma mark - Gratitudes (Map)

typedef void(^OnethingClientAPIGratitudeBinsSuccessBlock)(NSArray* gratitudeBins);

- (void)gratitudesForNeighbourhood:(NSString*)neighbourhood
                              city:(NSString*)city
                       apiKey:(NSString*)apiKey 
                     anchorId:(NSInteger)anchorId
                       isMine:(BOOL)isMine
                      perPage:(NSInteger)perPage
                      startup:(OnethingClientAPIStartupBlock)startup 
                      success:(OnethingClientAPIGratitudesSuccessBlock)success 
                      failure:(OnethingClientAPIFailureBlock)failure 
                   completion:(OnethingClientAPICompletionBlock)completion;

- (void)gratitudesForNeighbourhood:(NSString*)neighbourhood
                              city:(NSString*)city
                            apiKey:(NSString*)apiKey 
                            isMine:(BOOL)isMine
                           perPage:(NSInteger)perPage
                           startup:(OnethingClientAPIStartupBlock)startup 
                           success:(OnethingClientAPIGratitudesSuccessBlock)success 
                           failure:(OnethingClientAPIFailureBlock)failure 
                        completion:(OnethingClientAPICompletionBlock)completion;

- (void)gratitudeMapForLocation:(CLLocationCoordinate2D)location
                         apiKey:(NSString*)apiKey 
                        startup:(OnethingClientAPIStartupBlock)startup 
                        success:(OnethingClientAPIGratitudeBinsSuccessBlock)success 
                        failure:(OnethingClientAPIFailureBlock)failure 
                     completion:(OnethingClientAPICompletionBlock)completion;


@end
