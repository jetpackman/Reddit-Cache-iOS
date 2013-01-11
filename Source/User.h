//
//  User.h
//  onething
//
//  Created by Dane Carr on 12-02-10.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property (nonatomic, strong) NSString* userId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *apiKey;
@property (nonatomic, assign) BOOL registeredUser;
@property (nonatomic, strong) NSString *receivesNewsletter;

@end
