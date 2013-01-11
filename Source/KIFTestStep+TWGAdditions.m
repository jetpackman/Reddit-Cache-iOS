//
//  KIFTestStep+TWGAdditions.m
//  onething
//
//  Created by Anthony Wong on 12-05-25.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import "KIFTestStep+TWGAdditions.h"
#import "LandingPageViewController.h"
#import "OneThingAppDelegate.h"

@implementation KIFTestStep (TWGAdditions)

#pragma mark - Factory Steps
+ (id) stepToReset
{
    return [KIFTestStep stepWithDescription:@"Reset the application state." executionBlock:^(KIFTestStep *step, NSError **error) {
        BOOL successfulReset = YES;
        
        // Do the actual reset for your app. Set successfulReset = NO if it fails.
        
        // Blow all keys
        NSDictionary *defaultsDictionary = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
        
        if ([defaultsDictionary valueForKey:@"UserDefaultsLoggedIn"]) {
            for (NSString *key in [defaultsDictionary allKeys]) {
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
            }
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            // Go back to landing page
            
            OneThingAppDelegate* appDelegate = (OneThingAppDelegate*) [UIApplication sharedApplication].delegate;
            UINavigationController* rootNav = (UINavigationController*) appDelegate.window.rootViewController;
            [rootNav popToRootViewControllerAnimated:NO];
            [rootNav dismissModalViewControllerAnimated:NO];
            
        }

        KIFTestCondition(successfulReset, error, @"Failed to reset some part of the application.");
        
        return KIFTestStepResultSuccess;
    }];
}

#pragma mark - Step Collections
+ (NSArray*) stepsToSignOut
{
    NSMutableArray* steps = [NSMutableArray array];
    
    //Open the drawer
    [steps addObject:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Menu Drawer"]];
    
    //Tap the settings menu
    [steps addObject:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Settings"]];
    
    //Tap the signout button
    [steps addObject:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Sign Out"]];
    
    return steps;
}

+ (NSArray*) stepsToLogin
{
    NSMutableArray* steps = [NSMutableArray array];

    [steps addObject:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"I'm returning"]];
    [steps addObject:[KIFTestStep stepToEnterText:@"anthony@twg.ca" intoViewWithAccessibilityLabel:@"Email"]];
    [steps addObject:[KIFTestStep stepToEnterText:@"twong" intoViewWithAccessibilityLabel:@"Password"]];
    [steps addObject:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Sign In"]];
    [steps addObject:[KIFTestStep stepToWaitForViewWithAccessibilityLabel:@"My Gratitude Screen"]];

    return steps;
}


@end

