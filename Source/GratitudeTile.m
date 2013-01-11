//
//  GratitudeTile.m
//  onething
//
//  Created by Dane Carr on 12-02-21.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import "GratitudeTile.h"

@implementation GratitudeTile

@synthesize bodyLabel = _bodyLabel;
@synthesize createdAtLabel = _createdAtLabel;
@synthesize activityIndicator = _activityIndicator;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
                
        self.bodyLabel = [[UILabel alloc] init];
        [self.bodyLabel setFont:[UIFont fontWithName:@"QuattrocentoSans-Bold" size:17]];
        [self.bodyLabel setTextColor:[UIColor whiteColor]];
        [self.bodyLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [self.bodyLabel setNumberOfLines:0];
        [self.bodyLabel setAdjustsFontSizeToFitWidth:NO];
        [self.bodyLabel setTextAlignment:NSTextAlignmentCenter];
        [self.bodyLabel setBackgroundColor:[UIColor clearColor]];
        [self.bodyLabel setOpaque:NO];
        [self.bodyLabel setShadowColor:[UIColor clearColor]];
        
        self.createdAtLabel = [[UILabel alloc] init];
        [self.createdAtLabel setFont:[UIFont fontWithName:@"QuattrocentoSans-Bold" size:12]];
        [self.createdAtLabel setTextColor:[UIColor colorWithRed:120.0/255.0 green:139.0/255.0 blue:169.0/255.0 alpha:1.0]];
        [self.createdAtLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        [self.createdAtLabel setNumberOfLines:1];
        [self.createdAtLabel setAdjustsFontSizeToFitWidth:NO];
        [self.createdAtLabel setTextAlignment:NSTextAlignmentCenter];
        [self.createdAtLabel setBackgroundColor:[UIColor clearColor]];
        [self.createdAtLabel setOpaque:NO]; 
        
        self.activityIndicator = [[UIActivityIndicatorView alloc] init];
        [self.activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
        [self.activityIndicator setHidesWhenStopped:YES];
        
        [self addSubview:self.bodyLabel];
        [self.bodyLabel setFrame:CGRectMake(self.center.x, self.center.y, 0, 0)];
        
        [self addSubview:self.createdAtLabel];
        [self.createdAtLabel setFrame:CGRectMake(self.bodyLabel.center.x, self.bodyLabel.frame.origin.y + self.bodyLabel.frame.size.height + 5, 0, 0)];
        
        [self addSubview:self.activityIndicator];
        [self.activityIndicator setCenter:self.center];
        
        [self.bodyLabel setAutoresizingMask:UIViewAutoresizingNone];
        [self.createdAtLabel setAutoresizingMask:UIViewAutoresizingNone];
        [self.activityIndicator setAutoresizingMask:UIViewAutoresizingNone];
        
    }
    return self;
}

- (void)showLoadingIndicator 
{
    self.bodyLabel.hidden = YES;
    self.createdAtLabel.hidden = YES;
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
}

- (void)hideLoadingIndicator 
{
    self.activityIndicator.hidden = YES;
    [self.activityIndicator stopAnimating];
    self.bodyLabel.hidden = NO;
    self.createdAtLabel.hidden = NO;
}

- (void)setBody:(NSString *)body createdAt:(NSString *)createdAt
{
    self.bodyLabel.text = body;
    self.createdAtLabel.text = createdAt;
    [self resizeLabels];
}

- (void)resizeLabels 
{
    CGSize bodyLabelSize = [self.bodyLabel.text sizeWithFont:self.bodyLabel.font constrainedToSize:CGSizeMake(260, self.frame.size.height) lineBreakMode:NSLineBreakByWordWrapping];
    self.bodyLabel.bounds = CGRectMake(0, 0, bodyLabelSize.width + 4, bodyLabelSize.height + 4);
    
    CGSize createdAtLabelSize = [self.createdAtLabel.text sizeWithFont:self.createdAtLabel.font forWidth:self.frame.size.width lineBreakMode:NSLineBreakByTruncatingTail];
    self.createdAtLabel.bounds = CGRectMake(0, 0, createdAtLabelSize.width + 4, createdAtLabelSize.height + 4);
    self.createdAtLabel.frame = CGRectMake(self.createdAtLabel.frame.origin.x, self.bodyLabel.frame.origin.y + self.bodyLabel.frame.size.height + 5, self.createdAtLabel.frame.size.width, self.createdAtLabel.frame.size.height);
}

@end
