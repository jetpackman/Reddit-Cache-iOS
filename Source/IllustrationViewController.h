//
//  IllustrationViewController.h
//  onething
//
//  Created by Anthony Wong on 2012-08-22.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IllustrationViewController : UIViewController <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *forward;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backward;
@property (nonatomic, assign) BOOL firstLoad;
@property (nonatomic, assign) int loadBalancer;
- (IBAction)goBack:(id)sender;
- (IBAction)goForward:(id)sender;

@end
