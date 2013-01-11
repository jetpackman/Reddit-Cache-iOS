//
//  KIFTestStep+TWGAdditions.h
//  onething
//
//  Created by Anthony Wong on 12-05-25.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import "KIFTestStep.h"

@interface KIFTestStep (TWGAdditions)

+ (id) stepToReset;
+ (NSArray*)stepsToSignOut;
+ (NSArray*)stepsToLogin;

@end