//
//  OneThingAppDelegate.m
//  onething
//
//  Created by Dane Carr on 12-02-10.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import "OneThingAppDelegate.h"

#import <HockeySDK/HockeySDK.h>

#import "Flurry.h"
#import "LandingPageViewController.h"
#import "User.h"

#if RUN_KIF_TESTS
#import "TestController.h"
#endif


@implementation OneThingAppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Hockey App
    [[BITHockeyManager sharedHockeyManager] configureWithBetaIdentifier:@"de8611589ee0192da627badfbdaf4c99"
                                                         liveIdentifier:@"3c5a0e8b0fecdcc990266fec44a5cee0"
                                                               delegate:self];
    [[BITHockeyManager sharedHockeyManager] startManager];
    
    // Setup Flurry.    
    [Flurry startSession:@"V76JWT2NMVVZ2D9N2CS5"];
    
    // Setup local notifications.
    UILocalNotification *localNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNotification) {
        [[NSNotificationCenter defaultCenter] postNotificationName:CreateGratitudeNotification object:nil];
    }
    
    // Customize the appearance.
    [self customizeNavigationBar];

    // Root navigation
    LandingPageViewController *landingPageViewController = [[LandingPageViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:landingPageViewController];
    
    navigationController.view.autoresizingMask = (UIViewAutoresizingFlexibleHeight);
//    navigationController.view.contentMode =UIViewContentModeScaleAspectFill;
    
    // Create the window.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
    
#if RUN_KIF_TESTS
    // Disable auto login
    [defaults setBool:NO forKey:@"UserDefaultsLoggedIn"];
    
    [[TestController sharedInstance] startTestingWithCompletionBlock:^{
        // Exit after the tests complete so that CI knows we're done
        exit([[TestController sharedInstance] failureCount]);
    }];
#endif
    
    return YES;
}

- (void)application:(UIApplication*)application didReceiveLocalNotification:(UILocalNotification *)notification {
    // Only fire notification if we came from background into foreground
    if (application.applicationState != UIApplicationStateActive) {
        [[NSNotificationCenter defaultCenter] postNotificationName:CreateGratitudeNotification object:nil];
    } else {
        NSLog(@"Notificaion recieved with app open");
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"1Thing" message:@"Reminder to record a gratitude!" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Record Gratitude", nil];
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    // the user clicked one of the OK/Cancel buttons
    if (buttonIndex == 1) {
        NSLog(@"Create a gratitude");
        [[NSNotificationCenter defaultCenter] postNotificationName:CreateGratitudeNotification object:nil];
    } else {
        NSLog(@"Cancel");
    }
}

- (void)customizeNavigationBar {
    UIImage *navBarBackground = [[UIImage imageNamed:@"bg_nav_bar"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    [[UINavigationBar appearance] setBackgroundImage:navBarBackground forBarMetrics:UIBarMetricsDefault];
    
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"QuattrocentoSans-Bold" size:22], UITextAttributeFont, nil]];
    
    [[UIToolbar appearance] setBackgroundImage:navBarBackground forToolbarPosition:UIToolbarPositionBottom barMetrics:UIBarMetricsDefault];
    
    UIImage *barButtonBackground = [[UIImage imageNamed:@"bar_button_normal.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(14, 6, 14, 5)];
    UIImage *barButtonBackgroundHighlighted = [[UIImage imageNamed:@"bar_button_normal_tap.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(14, 6, 14, 5)];
    UIImage *backBarButtonBackground = [[UIImage imageNamed:@"bar_button_back.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 13, 14, 5)];
    UIImage *backBarButtonBackgroundHighlighted = [[UIImage imageNamed:@"bar_button_back_tap.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 13, 14, 5)];
    
    [[UIBarButtonItem appearance] setBackgroundImage:barButtonBackground forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearance] setBackgroundImage:barButtonBackgroundHighlighted forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backBarButtonBackground forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backBarButtonBackgroundHighlighted forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
}
							
- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    
}
- (void)application:(UIApplication *)application willChangeStatusBarFrame:(CGRect)newStatusBarFrame {
    
}

- (void)application:(UIApplication *)application didChangeStatusBarFrame:(CGRect)oldStatusBarFrame {
    
}

// Hockey App 
-(NSString *)customDeviceIdentifier {
#ifdef CONFIGURATION_AdHoc
    if ([[UIDevice currentDevice] respondsToSelector:@selector(uniqueIdentifier)])
        return [[UIDevice currentDevice] performSelector:@selector(uniqueIdentifier)];
#endif
    return nil;
}

@end
