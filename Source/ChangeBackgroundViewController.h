//
//  ChangeBackgroundViewController.h
//  onething
//
//  Created by Dane Carr on 12-03-01.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface ChangeBackgroundViewController : BaseViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) UIBarButtonItem *saveButton;

- (IBAction)showImagePicker:(id)sender;
- (void)saveBackground:(id)sender;
- (UIImage*)resizeImage:(UIImage*)sourceImage;

@end
