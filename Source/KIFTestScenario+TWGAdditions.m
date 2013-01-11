//
//  KIFTestScenario+TWGAdditions.m
//  onething
//
//  Created by Anthony Wong on 12-05-25.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import "KIFTestScenario+TWGAdditions.h"
#import "KIFTestStep+TWGAdditions.h"
#import "KIFTestStep.h"

@implementation KIFTestScenario (TWGAdditions)

+ (id)scenarioToLoginAndSignout;
{
    KIFTestScenario *scenario = [KIFTestScenario scenarioWithDescription:@"Test that a user can successfully log in and signout"];
    [scenario addStep:[KIFTestStep stepToReset]];
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"I'm returning"]];
    [scenario addStep:[KIFTestStep stepToEnterText:@"anthony@twg.ca" intoViewWithAccessibilityLabel:@"Email"]];
    [scenario addStep:[KIFTestStep stepToEnterText:@"twong" intoViewWithAccessibilityLabel:@"Password"]];
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Sign In"]];
    
    // Verify login
    [scenario addStep:[KIFTestStep stepToWaitForViewWithAccessibilityLabel:@"My Gratitude Screen"]];
    
    // Tap the menu drawer buton
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Menu Drawer"]];
    
    // Tap 'Settings'
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Settings"]];
    
    // Verify
    [scenario addStep:[KIFTestStep stepToWaitForViewWithAccessibilityLabel:@"Settings Screen"]];
    
    // Signout
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Sign Out"]];
    
    return scenario;
}

+ (id)scenarioToSignUp
{
    KIFTestScenario *scenario = [KIFTestScenario scenarioWithDescription:@"Test that a user can signup"];
    [scenario addStep:[KIFTestStep stepToReset]];
    
    [scenario addStep:[KIFTestStep stepToReset]];
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"I'm new"]];
    [scenario addStep:[KIFTestStep stepToEnterText:@"123 DELETE ME" intoViewWithAccessibilityLabel:@"Name"]];
    [scenario addStep:[KIFTestStep stepToEnterText:@"123@DELETE.ME" intoViewWithAccessibilityLabel:@"Email"]];
    [scenario addStep:[KIFTestStep stepToEnterText:@"12345" intoViewWithAccessibilityLabel:@"Password"]];
    [scenario addStep:[KIFTestStep stepToEnterText:@"12345" intoViewWithAccessibilityLabel:@"Password again"]];
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Sign up"]];
    
    // Verify login
    [scenario addStep:[KIFTestStep stepToWaitForViewWithAccessibilityLabel:@"My Gratitude Screen"]];
    
    return scenario;
}


+ (id)scenarioToCreateGratitude
{
    KIFTestScenario *scenario = [KIFTestScenario scenarioWithDescription:@"Test that a user can create a gratitude"];
    [scenario addStep:[KIFTestStep stepToReset]];
    [scenario addStepsFromArray:[KIFTestStep stepsToLogin]];
    
    // Tap create gratitude
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Create a Gratitude"]];
    
    // Wait for composer
    [scenario addStep:[KIFTestStep stepToWaitForViewWithAccessibilityLabel:@"Create Gratitude"]];
    
    // Fill in the body
    [scenario addStep:[KIFTestStep stepToEnterText:@"I am grateful for automated integration testing" intoViewWithAccessibilityLabel:@"Gratitude Body"]];
    
    // Tap the done button
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Done"]];
    
    [scenario addStep:[KIFTestStep stepToWaitForViewWithAccessibilityLabel:@"My Gratitude Screen"]];
    
    return scenario;
    
}

+ (id)scenarioToEmailAGratitude
{
    KIFTestScenario *scenario = [KIFTestScenario scenarioWithDescription:@"Test that a user can email a gratitude"];
    [scenario addStep:[KIFTestStep stepToReset]];
    [scenario addStepsFromArray:[KIFTestStep stepsToLogin]];
    
    // Tap the first my gratitude cell to open the drawer
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"My Gratitude Cell"]];
    
    // Wait for the drawer to open
    [scenario addStep:[KIFTestStep stepToWaitForViewWithAccessibilityLabel:@"Share Gratitude Cell"]];
    
    // Tap on Email
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Share via Email"]];
    
    
    return scenario;
    
}

+ (id)scenarioToPublishGratitude
{
    KIFTestScenario *scenario = [KIFTestScenario scenarioWithDescription:@"Test that a user can publish a gratitude"];
    [scenario addStep:[KIFTestStep stepToReset]];
    [scenario addStepsFromArray:[KIFTestStep stepsToLogin]];
    
    // Tap the first my gratitude cell to open the drawer
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"My Gratitude Cell"]];
    
    // Wait for the drawer to open
    [scenario addStep:[KIFTestStep stepToWaitForViewWithAccessibilityLabel:@"Share Gratitude Cell"]];
    
    // Tap on publish button
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Publish Gratitude"]];
    
    // Wait for thumbprint
    [scenario addStep:[KIFTestStep stepToWaitForViewWithAccessibilityLabel:@"Published Gratitude"]];
    
    return scenario;
}

/*
 This is a fragile test... currently depends on a bunch of factors of such as whether the user is already logged into FB or not, or the current state of the user-tokens. Currently don't see a way to automate things when presented in the web-view format ot login or what not.
 */

+ (id)scenarioToShareOnFacebook
{
    
    KIFTestScenario *scenario = [KIFTestScenario scenarioWithDescription:@"Test that a user can share on Facebook"];
    
    [scenario addStep:[KIFTestStep stepToReset]];
    [scenario addStepsFromArray:[KIFTestStep stepsToLogin]];
    
    // Tap the first my gratitude cell to open the drawer
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"My Gratitude Cell"]];
    
    // Wait for the drawer to open
    [scenario addStep:[KIFTestStep stepToWaitForViewWithAccessibilityLabel:@"Share Gratitude Cell"]];
    
    // Tap on Facebook button
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Share on Facebook"]];
    
    // Tap on 'Yes'
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Yes"]];
    
    // Wait for success message
    [scenario addStep:[KIFTestStep stepToWaitForViewWithAccessibilityLabel:@"Shared!"]];
    
    return scenario;
}

+ (id)scenarioToCheckMenus
{
    KIFTestScenario *scenario = [KIFTestScenario scenarioWithDescription:@"Test that the user can go through all the menus"];
    [scenario addStep:[KIFTestStep stepToReset]];
    [scenario addStepsFromArray:[KIFTestStep stepsToLogin]];
    
    // Tap the menu drawer buton
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Menu Drawer"]];
     
    // Tap calendar
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Calendar"]];
    
    // Verify Calendar came up
    [scenario addStep:[KIFTestStep stepToWaitForViewWithAccessibilityLabel:@"Calendar Screen"]];
    
    // Tap the menu drawer buton
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Menu Drawer"]];
    
    // Tap 'Global Gratitude' (shared gratitudes)
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Global Gratitude"]];
    
    // Verify
    [scenario addStep:[KIFTestStep stepToWaitForViewWithAccessibilityLabel:@"Shared Gratitude Screen"]];
    
    // Tap the menu drawer buton
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Menu Drawer"]];
    
    // Tap 'Gratitude Map'
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Gratitude Map"]];
    
    // Verify
    [scenario addStep:[KIFTestStep stepToWaitForViewWithAccessibilityLabel:@"Map Screen"]];
    
    // Tap the menu drawer buton
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Menu Drawer"]];
    
    // Tap the top words
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Top Words"]];
    
    // Verify
    [scenario addStep:[KIFTestStep stepToWaitForViewWithAccessibilityLabel:@"Top Words Screen"]];
    
    // Tap the menu drawer buton
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Menu Drawer"]];
    
    // Tap 'Word Cloud'
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Word Cloud"]];
    
    // Verify
    [scenario addStep:[KIFTestStep stepToWaitForViewWithAccessibilityLabel:@"Word Cloud Screen"]];
    
    // Tap the menu drawer buton
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Menu Drawer"]];
    
    // Tap 'Random'
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Random"]];

    // Verify
    [scenario addStep:[KIFTestStep stepToWaitForViewWithAccessibilityLabel:@"Random Gratitude Screen"]];
    
    // Tap the menu drawer buton
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Menu Drawer"]];
    
    // Tap 'Settings'
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Settings"]];
    
    // Verify
    [scenario addStep:[KIFTestStep stepToWaitForViewWithAccessibilityLabel:@"Settings Screen"]];
    
    // Tap the menu drawer buton
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Menu Drawer"]];
    
    // Tap 'Journal'
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Journal"]];
    
    // Verify
    [scenario addStep:[KIFTestStep stepToWaitForViewWithAccessibilityLabel:@"My Gratitude Screen"]];
    
    
    return scenario;
      
    
}

+ (id)scenarioToEditGratitude
{
    KIFTestScenario *scenario = [KIFTestScenario scenarioWithDescription:@"Test that a user can create a gratitude"];
    [scenario addStep:[KIFTestStep stepToReset]];
    [scenario addStepsFromArray:[KIFTestStep stepsToLogin]];
    
    // Reveal the edit button
    [scenario addStep:[KIFTestStep stepToSwipeViewWithAccessibilityLabel:@"My Gratitude Cell" inDirection:KIFSwipeDirectionLeft]];
    
    // Tap the edit button
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Edit"]];
    
    // Fill in the body
    [scenario addStep:[KIFTestStep stepToEnterText:@"I am grateful for automated integration testing" intoViewWithAccessibilityLabel:@"Gratitude Body"]];
    
    // Tap the done button
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Done"]];
    
    [scenario addStep:[KIFTestStep stepToWaitForViewWithAccessibilityLabel:@"My Gratitude Screen"]];
    
    return scenario;
}

+ (id)scenarioToLikeAGratitude
{
    KIFTestScenario *scenario = [KIFTestScenario scenarioWithDescription:@"Test that the user can like a gratitude"];
    [scenario addStep:[KIFTestStep stepToReset]];
    [scenario addStepsFromArray:[KIFTestStep stepsToLogin]];
    
    // Tap the menu drawer buton
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Menu Drawer"]];
    
    // Tap 'Global Gratitude' (shared gratitudes)
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Global Gratitude"]];
    
    // Verify
    [scenario addStep:[KIFTestStep stepToWaitForViewWithAccessibilityLabel:@"Shared Gratitude Screen"]];
    
    // Wait for sharing button
    [scenario addStep:[KIFTestStep stepToWaitForViewWithAccessibilityLabel:@"Like Gratitude"]];

    // Tap the sharing button
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Like Gratitude"]];
    
    // Verify
    [scenario addStep:[KIFTestStep stepToWaitForViewWithAccessibilityLabel:@"Like Gratitude" value:@"Liked a Gratitude" traits:UIAccessibilityTraitNone]];
    
    return scenario;
}

+ (id)scenarioToEditProfile
{
    KIFTestScenario *scenario = [KIFTestScenario scenarioWithDescription:@"Test that the user can go through all the menus"];
    [scenario addStep:[KIFTestStep stepToReset]];
    [scenario addStepsFromArray:[KIFTestStep stepsToLogin]];
    
    // Tap the menu drawer buton
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Menu Drawer"]];
    
    // Tap 'Settings'
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Settings"]];
    
    // Tap 'Personal Details'
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Personal Details"]];
    
    // Enter text in name
    [scenario addStep:[KIFTestStep stepToEnterText:@"Chicken Feet" intoViewWithAccessibilityLabel:@"Name Field"]];
    
    // Enter email
    [scenario addStep:[KIFTestStep stepToEnterText:@"anthony@twg.ca" intoViewWithAccessibilityLabel:@"Email Field"]];
    
    // Enter password
    [scenario addStep:[KIFTestStep stepToEnterText:@"twong" intoViewWithAccessibilityLabel:@"Password Field"]];
    
    // Enter password again
    [scenario addStep:[KIFTestStep stepToEnterText:@"twong" intoViewWithAccessibilityLabel:@"Password again Field"]];
    
    // Tap 'Save'
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Save"]];
    
    // Verify
    [scenario addStep:[KIFTestStep stepToWaitForViewWithAccessibilityLabel:@"Settings Screen"]];
    
    return scenario;
}

@end

