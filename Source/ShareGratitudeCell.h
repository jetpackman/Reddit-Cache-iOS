//
//  ShareGratitudeCell.h
//  onething
//
//  Created by Dane Carr on 12-03-05.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShareGratitudeCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIButton *onethingShareButton;
@property (nonatomic, weak) IBOutlet UIButton *emailShareButton;
@property (nonatomic, weak) IBOutlet UIButton *smsShareButton;
@property (nonatomic, weak) IBOutlet UIButton *twitterShareButton;
@property (nonatomic, weak) IBOutlet UIButton *facebookShareButton;
@property (nonatomic, weak) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet UILabel *sharingLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *sharingActivitySpinner;
@property (weak, nonatomic) IBOutlet UIImageView *sharingImage;


- (void)recenterImageAndLabel;
- (void)recenterSpinnerAndLabel;
@end
