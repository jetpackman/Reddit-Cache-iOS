//
//  PublicGratitudeCell.m
//  onething
//
//  Created by Dane Carr on 12-04-17.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import "PublicGratitudeCell.h"
#import "BaseGratitudeTableView.h"
#import "OnethingClientAPI.h"

@implementation PublicGratitudeCell

@synthesize gratitude = _gratitude;
@synthesize bodyLabel = _bodyLabel;
@synthesize createdAtLabel = _createdAtLabel;
@synthesize timePressedLabel = _timePressedLabel;
@synthesize likeButton = _likeButton;

#define CELL_DEFAULT_HEIGHT 60.0f
#define CELL_PADDING_TOP 13.0f
#define CELL_PADDING_BOTTOM 21.0f

#define GRATITUDE_TEXT_WIDTH_WITH_BUTTON 231.0f

- (void) awakeFromNib
{
    [self.likeButton setAccessibilityLabel:@"Like Gratitude"];
}
+ (CGFloat)heightForGratitude:(Gratitude *)gratitude 
{
    // Calculate the height of the text
    CGFloat textHeight = [gratitude.body sizeWithFont:[UIFont systemFontOfSize:16.0f] constrainedToSize:CGSizeMake(GRATITUDE_TEXT_WIDTH_WITH_BUTTON, 1000.0f) lineBreakMode:NSLineBreakByWordWrapping].height;
    
    // Calculate the actual height
    CGFloat actualHeight = (CELL_PADDING_TOP + textHeight + CELL_PADDING_BOTTOM);
    
    // Return the greater of actual height and minimum (default) height
    return MAX(actualHeight, CELL_DEFAULT_HEIGHT);
}

+ (NSString*)formatDate:(NSDate *)date
{
    static NSDateFormatter *df;
    if (!df) {
        df = [[NSDateFormatter alloc] init];
        // e.g. "10:29 PM | Apr. 18, 2012"
        [df setDateFormat:@"h:mm a | MMM d, yyyy"];
    }
    return [df stringFromDate:date];
}

- (void)prepareForReuse
{
    self.gratitude = nil;
}

- (void)likeButtonPressed:(id)sender 
{
    self.gratitude.likeCount++;
    self.gratitude.liked = YES;
    
    [self.likeButton setAccessibilityValue:@"Liked a Gratitude"];
    [self configureWithGratitude:self.gratitude];
    UIView* v = self;
    
    while(true) {
        v = v.superview;
        if([v isKindOfClass:[BaseGratitudeTableView class]]) {
            break;
        }
    }
    
    BaseGratitudeTableView *bv = (BaseGratitudeTableView*)v;
    
    // TODO: This is temporary. A TableCell shouldn't neccessarily be do an API call. Nore should the tableView have a copy of the user
    [[OnethingClientAPI sharedClient] likeGratitude:self.gratitude
                                             apiKey:bv.user.apiKey
                                           duration:bv.duration*1000
                                            startup:^(NSOperation* operation) {
                                                
                                            }success:^(Gratitude* grat) {
                                                [self configureWithGratitude:grat];
                                                
                                            }failure:^(NSHTTPURLResponse* response, NSError *error){
                                                
                                            }completion:nil
     
     ];
    
}


- (PublicGratitudeCell*)configureWithGratitude:(Gratitude *)gratitude
{
    // Set gratitude property
    self.gratitude = gratitude;
    [self.likeButton setAccessibilityLabel:[NSString stringWithFormat:@"like button with %d likes", gratitude.likeCount]];
    // Set appearance of like button
    if (self.gratitude.liked) {
        // Blue fingerprint graphics are only used for disabled state
        self.likeButton.enabled = NO;
        [self.likeButton removeTarget:self action:@selector(likeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
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
    }
    else {
        // Tappable like buttons will always be a grey fingerprint
        self.likeButton.enabled = YES;
        [self.likeButton setTitle:[NSString stringWithFormat:@"%d", self.gratitude.likeCount] forState:UIControlStateNormal];
        [self.likeButton addTarget:self action:@selector(likeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

    }
    
    // Set label content and resize to fit
    self.bodyLabel.text = self.gratitude.body;
    CGFloat textHeight = [gratitude.body sizeWithFont:[UIFont systemFontOfSize:16.0f] constrainedToSize:CGSizeMake(self.bodyLabel.frame.size.width, 1000.0f) lineBreakMode:NSLineBreakByWordWrapping].height;
    self.bodyLabel.frame = CGRectMake(20, 13, self.bodyLabel.frame.size.width, textHeight);
    if (gratitude.hasLocation && self.gratitude.city) {
        // Public gratitudes show city instead of neighbourhood
        self.createdAtLabel.text = [NSString stringWithFormat:@"%@ | in %@", [PublicGratitudeCell formatDate:self.gratitude.createdAt], self.gratitude.city];
    }
    else {
        self.createdAtLabel.text = [PublicGratitudeCell formatDate:self.gratitude.createdAt];
    }
    
    NSInteger milliseconds = [gratitude.likedTime integerValue];
    NSInteger totalSeconds = milliseconds / 1000;

    NSInteger seconds = totalSeconds % 60;
    NSInteger minutes = totalSeconds / 60;
    NSInteger hours = minutes / 60;
    minutes = minutes % 60;
    
    
    self.timePressedLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
    return self;

}



@end
