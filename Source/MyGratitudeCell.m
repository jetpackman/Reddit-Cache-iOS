//
//  MyGratitudeCell.m
//  onething
//
//  Created by Dane Carr on 12-02-14.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import "MyGratitudeCell.h"

@implementation MyGratitudeCell

@synthesize gratitude = _gratitude;
@synthesize bodyLabel = _bodyLabel;
@synthesize createdAtLabel = _createdAtLabel;
@synthesize likeButton = _likeButton;

#define CELL_DEFAULT_HEIGHT 60.0f
#define CELL_PADDING_TOP 13.0f
#define CELL_PADDING_BOTTOM 21.0f

#define GRATITUDE_TEXT_WIDTH_NO_BUTTON 280.0f
#define GRATITUDE_TEXT_WIDTH_WITH_BUTTON 231.0f

- (void)awakeFromNib
{
//    [self.likeButton setAccessibilityLabel: @"Test"];
}


+ (CGFloat)heightForGratitude:(Gratitude *)gratitude
{
    // Calculate the height of the text
    CGFloat textHeight = [gratitude.body sizeWithFont:[UIFont systemFontOfSize:16.0f] constrainedToSize:CGSizeMake((gratitude.isPublic ? GRATITUDE_TEXT_WIDTH_WITH_BUTTON : GRATITUDE_TEXT_WIDTH_NO_BUTTON), 1000.0f) lineBreakMode:NSLineBreakByWordWrapping].height;
    
    // Calculate the actual height
    CGFloat actualHeight = (CELL_PADDING_TOP + textHeight + CELL_PADDING_BOTTOM);
    
    // Return the greater of actual height and minimum (default) height
    return MAX(actualHeight, CELL_DEFAULT_HEIGHT);
}

+ (NSString*)formatDate:(NSDate *)date
{
    static NSDateFormatter *df;
    if (!df) {
//        df = [[NSDateFormatter alloc] init];
//        [df setTimeStyle:NSDateFormatterShortStyle];
//        [df setDateStyle:NSDateFormatterNoStyle];
        df = [[NSDateFormatter alloc] init];
        // e.g. "10:29 PM | Apr. 18, 2012"
        [df setDateFormat:@"h:mm a | MMM d, yyyy"];
    }
    return [df stringFromDate:date];
}

- (void)hideLikes {
    if (self.likeButton.hidden){
        return;
    }
    // Hide the like button
    self.likeButton.hidden = YES;
    
    // Resize cell labels
    CGRect bodyFrame = self.bodyLabel.frame;
    CGRect dateFrame = self.createdAtLabel.frame;
    bodyFrame.size.width = GRATITUDE_TEXT_WIDTH_NO_BUTTON;
    dateFrame.size.width = GRATITUDE_TEXT_WIDTH_NO_BUTTON;
    self.bodyLabel.frame = bodyFrame;
    self.createdAtLabel.frame = dateFrame;
}

- (void)showLikes {
    if (!self.likeButton.hidden) {
        return;
    }
    
    // Resize cell labels
    CGRect bodyFrame = self.bodyLabel.frame;
    CGRect dateFrame = self.createdAtLabel.frame;
    bodyFrame.size.width = GRATITUDE_TEXT_WIDTH_WITH_BUTTON;
    dateFrame.size.width = GRATITUDE_TEXT_WIDTH_WITH_BUTTON;
    self.bodyLabel.frame = bodyFrame;
    self.createdAtLabel.frame = dateFrame;
    
    // Show fingerprint image and label
    self.likeButton.hidden = NO;


}

- (void)prepareForReuse
{
    self.gratitude = nil;
}

- (MyGratitudeCell*)configureWithGratitude:(Gratitude *)gratitude AndTopWord:(NSString*)topWord
{
    self.bodyLabel.key = topWord;
    return [self configureWithGratitude:gratitude];
}

- (MyGratitudeCell*)configureWithGratitude:(Gratitude *)gratitude 
{
    if(!self.bodyLabel.key) {
        self.bodyLabel.key = @"";
    }

    // Set gratitude property
    self.gratitude = gratitude;
    self.likeButton.enabled = NO;

    //Accessibility
    NSString *likes = [NSString stringWithFormat:@"%d likes", gratitude.likeCount];
    [self.likeButton setAccessibilityLabel: likes];
    
    // Set appearance of like button
    if (self.gratitude.isPublic) {
        // Blue fingerprint graphics are only used for disabled state
        [self showLikes];
        [self.likeButton setTitle:@"" forState:UIControlStateDisabled];
        
        // Images 1 through 5 have numbers included, using white Helvetica Neue Bold 13.0
        switch (self.gratitude.likeCount) {
            case 0:
                [self.likeButton setBackgroundImage:[UIImage imageNamed:@"fingerprint_blue.png"] forState:UIControlStateDisabled];
                break;
            case 1:
                [self.likeButton setBackgroundImage:[UIImage imageNamed:@"fingerprint_blue_1.png"] forState:UIControlStateDisabled];
                break;
            case 2:
                [self.likeButton setBackgroundImage:[UIImage imageNamed:@"fingerprint_blue_2.png"] forState:UIControlStateDisabled];
                break;
            case 3:
                [self.likeButton setBackgroundImage:[UIImage imageNamed:@"fingerprint_blue_3.png"] forState:UIControlStateDisabled];
                break;
            case 4:
                [self.likeButton setBackgroundImage:[UIImage imageNamed:@"fingerprint_blue_4.png"] forState:UIControlStateDisabled];
                break;
            case 5:
                [self.likeButton setBackgroundImage:[UIImage imageNamed:@"fingerprint_blue_5.png"] forState:UIControlStateDisabled];
                break;
            default:
                [self.likeButton setBackgroundImage:[UIImage imageNamed:@"fingerprint_blue_6.png"] forState:UIControlStateDisabled];
                [self.likeButton setTitle:[NSString stringWithFormat:@"%d", self.gratitude.likeCount] forState:UIControlStateDisabled];
                break;
        }
    } else {
        [self hideLikes];
    }
    
    // Set content on labels and resize to fit
    self.bodyLabel.text = self.gratitude.body;
    CGFloat textHeight = [gratitude.body sizeWithFont:[UIFont systemFontOfSize:16.0f] constrainedToSize:CGSizeMake(self.bodyLabel.frame.size.width, 1000.0f) lineBreakMode:NSLineBreakByWordWrapping].height;
    self.bodyLabel.frame = CGRectMake(20, 13, self.bodyLabel.frame.size.width, textHeight);
    if (self.gratitude.hasLocation && self.gratitude.neighbourhood) {
        self.createdAtLabel.text = [NSString stringWithFormat:@"%@ | in %@", [MyGratitudeCell formatDate:self.gratitude.createdAt], self.gratitude.neighbourhood];
    }
    else {
        self.createdAtLabel.text = [MyGratitudeCell formatDate:self.gratitude.createdAt];
    }
    
    return self;
}

@end