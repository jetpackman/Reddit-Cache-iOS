//
//  ShareGratitudeCell.m
//  onething
//
//  Created by Dane Carr on 12-03-05.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import "ShareGratitudeCell.h"

@implementation ShareGratitudeCell

@synthesize onethingShareButton = _onethingShareButton;
@synthesize emailShareButton = _emailShareButton;
@synthesize smsShareButton = _smsShareButton;
@synthesize twitterShareButton = _twitterShareButton;
@synthesize facebookShareButton = _facebookShareButton;
@synthesize backgroundImage = _backgroundImage;
@synthesize sharingLabel = _sharingLabel;
@synthesize sharingActivitySpinner = _sharingActivitySpinner;
@synthesize sharingImage = _sharingImage;


- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self.onethingShareButton setIsAccessibilityElement:YES];
    [self.onethingShareButton setAccessibilityLabel:@"Publish Gratitude"];
    [self.facebookShareButton setIsAccessibilityElement:YES];
    [self.facebookShareButton setAccessibilityLabel:@"Share on Facebook"];
    [self.twitterShareButton setIsAccessibilityElement:YES];
    [self.twitterShareButton setAccessibilityLabel:@"Share on Twitter"];
    [self.emailShareButton setIsAccessibilityElement:YES];
    [self.emailShareButton setAccessibilityLabel:@"Share via Email"];
    [self.smsShareButton setIsAccessibilityElement:YES];
    [self.smsShareButton setAccessibilityLabel:@"Share via SMS"];

}

- (void)recenterImageAndLabel
{
    // Resize the label to just fit the amount of text it currently has:
    CGFloat labelWidth = [self.sharingLabel.text sizeWithFont:[UIFont systemFontOfSize:14.f]].width;
    
    // Get the width of the cell frame;
    CGFloat cellWidth = self.frame.size.width;
    
    // The total amount of width the image and label will take
    CGFloat totalWidth = labelWidth + self.sharingImage.frame.size.width;
    
    // Calculate the amount of padding ends
    CGFloat padding = (cellWidth - totalWidth)/2.f;
    
    // Move the image
    self.sharingImage.frame = CGRectMake(padding, self.sharingImage.frame.origin.y, self.sharingImage.frame.size.width, self.sharingImage.frame.size.height);
    
    // Move the label
    self.sharingLabel.frame = CGRectMake(padding + self.sharingImage.frame.size.width + 3, self.sharingLabel.frame.origin.y, labelWidth, self.sharingLabel.frame.size.height);
}

- (void)recenterSpinnerAndLabel
{
    // Resize the label to just fit the amount of text it currently has:
    CGFloat labelWidth = [self.sharingLabel.text sizeWithFont:[UIFont systemFontOfSize:14.f]].width;
    
    // Get the width of the cell frame;
    CGFloat cellWidth = self.frame.size.width;
    
    // The total amount of width the spinner and label will take
    CGFloat totalWidth = labelWidth + self.sharingActivitySpinner.frame.size.width;
    
    // Calculate the amount of padding ends
    CGFloat padding = (cellWidth - totalWidth)/2.f;
    
    // Move the image
    self.sharingActivitySpinner.frame = CGRectMake(padding, self.sharingActivitySpinner.frame.origin.y, self.sharingActivitySpinner.frame.size.width, self.sharingActivitySpinner.frame.size.height);
    
    // Move the label
    self.sharingLabel.frame = CGRectMake(padding + self.sharingActivitySpinner.frame.size.width + 3, self.sharingLabel.frame.origin.y, labelWidth, self.sharingLabel.frame.size.height);
}

@end
