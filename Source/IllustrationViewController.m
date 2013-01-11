//
//  IllustrationViewController.m
//  onething
//
//  Created by Anthony Wong on 2012-08-22.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import "IllustrationViewController.h"
#import "OneThingConstants.h"

@interface IllustrationViewController ()

@end

@implementation IllustrationViewController
@synthesize webView = _webView;
@synthesize forward = _forward;
@synthesize backward = _backward;
@synthesize firstLoad = _firstLoad;
@synthesize loadBalancer = _loadBalancer;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setTitle:@"Illustrated"];
    self.webView.delegate = self;
    self.webView.scalesPageToFit = YES;
    self.firstLoad = YES;
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:OnethingBlogURL]]];
}

- (void)viewDidUnload
{
    [self setWebView:nil];
    [self setForward:nil];
    [self setBackward:nil];

    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UIWebView Delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"Loading: %@", [request URL]);
    self.loadBalancer++;
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self updateButtons];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.loadBalancer--;
    if (self.loadBalancer){
        // We are not REALLY done until the loadBalancer is 0
        return;
    }
    
    [self webViewCompletelyFinishedLoading:webView];

}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    self.loadBalancer--;
    if (self.loadBalancer){
        // We are not REALLY done until the loadBalancer is 0
        return;
    }
    
    [self webViewCompletelyFinishedLoading:webView];
}

- (void)webViewCompletelyFinishedLoading:(UIWebView *)webView
{
    NSLog(@"Completely done loading");
       
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    self.loadBalancer = 0;
    [self updateButtons];
}

- (void)updateButtons
{
    self.forward.enabled = self.webView.canGoForward;
    self.backward.enabled = self.webView.canGoBack;
}

- (IBAction)goBack:(id)sender {
    if (self.webView.canGoBack) {
        [self.webView goBack];
    }
}

- (IBAction)goForward:(id)sender {
    if (self.webView.canGoForward) {
        [self.webView goForward];
    }
}
@end
