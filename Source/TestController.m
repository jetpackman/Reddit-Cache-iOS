//
//  TestController.m
//  onething
//
//  Created by Anthony Wong on 12-05-25.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import "TestController.h"
#import "KIFTestScenario+TWGAdditions.h"

@implementation TestController

- (void)initializeScenarios;
{
    [self addScenario:[KIFTestScenario scenarioToLoginAndSignout]];
    [self addScenario:[KIFTestScenario scenarioToSignUp]];
    [self addScenario:[KIFTestScenario scenarioToCreateGratitude]];
    [self addScenario:[KIFTestScenario scenarioToEmailAGratitude]];
    [self addScenario:[KIFTestScenario scenarioToPublishGratitude]];
    [self addScenario:[KIFTestScenario scenarioToShareOnFacebook]];
    [self addScenario:[KIFTestScenario scenarioToCheckMenus]];
    [self addScenario:[KIFTestScenario scenarioToEditGratitude]];
    [self addScenario:[KIFTestScenario scenarioToLikeAGratitude]];
    [self addScenario:[KIFTestScenario scenarioToEditProfile]];
}

@end
