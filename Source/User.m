//
//  User.m
//  onething
//
//  Created by Dane Carr on 12-02-10.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import "User.h"

@implementation User

@synthesize userId = _userId;
@synthesize name = _name;
@synthesize email = _email;
@synthesize apiKey = _apiKey;
@synthesize registeredUser = _registeredUser;
@synthesize receivesNewsletter = _receivesNewsletter;


#pragma mark - Debug

- (NSString*) description
{
    return [NSString stringWithFormat:@"\nID: %@\nName: %@\nemail: %@\napiKey:%@\n", self.userId, self.name, self.email, self.apiKey]; 
}

@end
