//
//  ChangeBackgroundViewController.m
//  onething
//
//  Created by Dane Carr on 12-03-01.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import "ChangeBackgroundViewController.h"
#include <math.h>

@implementation ChangeBackgroundViewController

@synthesize imageView = _imageView;
@synthesize saveButton = _saveButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(saveBackground:)];
        [self.navigationItem setRightBarButtonItem:self.saveButton];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"Gratitude Screen"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    UIImage *image;
    
    if ([defaults objectForKey:BackgroundImage]) {
        image = [UIImage imageWithData:[defaults objectForKey:BackgroundImage]];
    }
    else {
        image = [UIImage imageNamed:@"bg_create_gratitude.png"];
    }
    
    self.imageView.image = image;
}

- (IBAction)showImagePicker:(id)sender 
{
    // If multiple source types are available, show an actionsheet to choose
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
        
        TWGActionItem *newPhotoAction = [TWGActionItem actionItemWithTitle:@"Take a Photo" block:^{
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
            [imagePicker setDelegate:self];
            self.modalDisplayed = YES;
            [self presentViewController:imagePicker animated:YES completion:nil];
        }];
        
        TWGActionItem *existingPhotoAction = [TWGActionItem actionItemWithTitle:@"Choose a Photo" block:^{
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            [imagePicker setSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
            [imagePicker setDelegate:self];
            self.modalDisplayed = YES;
            [self presentViewController:imagePicker animated:YES completion:nil];
        }];
        
        TWGActionItem *cancelAction = [TWGActionItem actionItemWithTitle:@"Cancel"];
        
        TWGActionSheet *actionSheet = [TWGActionSheet actionSheetWithTitle:nil cancelItem:cancelAction destructiveItem:nil otherItems:[NSArray arrayWithObjects:newPhotoAction, existingPhotoAction, nil]];
        
        [actionSheet showInView:self.view];
    }
    
    // Otherwise display the first available source type
    else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
            [imagePicker setDelegate:self];
            self.modalDisplayed = YES;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
    else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            [imagePicker setSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
            [imagePicker setDelegate:self];
            self.modalDisplayed = YES;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
    else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            [imagePicker setDelegate:self];
            self.modalDisplayed = YES;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}
    
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark - Actions

- (void)saveBackground:(id)sender
{
    // Save image to NSUserDefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:UIImagePNGRepresentation(self.imageView.image) forKey:BackgroundImage];
    [defaults synchronize];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    self.modalDisplayed = NO;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info 
{
    UIImage *image;
    if ([info objectForKey:UIImagePickerControllerEditedImage]) {
        image = [info objectForKey:UIImagePickerControllerEditedImage];
    }
    else {
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    image = [self resizeImage:image];
    
    self.imageView.image = image;
    self.modalDisplayed = NO;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (UIImage*)resizeImage:(UIImage *)sourceImage 
{
    
    CGFloat targetWidth = 320;
    CGFloat targetHeight = 504;
    
    if (!(targetWidth == sourceImage.size.width && targetHeight == sourceImage.size.height)) {
        
        CGFloat scaleFactor = 0;
        CGFloat scaledWidth = 0;
        CGFloat scaledHeight = 0;
        CGPoint cornerPoint = CGPointMake(0, 0);
        
        CGFloat widthFactor = targetWidth / sourceImage.size.width;
        CGFloat heightFactor = targetHeight / sourceImage.size.height;
        
//        scaleFactor = MAX(widthFactor, heightFactor);
        scaledWidth = sourceImage.size.width * widthFactor;
        scaledHeight = sourceImage.size.height * heightFactor;
        
//        cornerPoint.x = (scaledWidth - targetWidth) * -0.5;
        
        UIGraphicsBeginImageContext(CGSizeMake(targetWidth, targetHeight));
        
        CGRect resizeRect = CGRectMake(cornerPoint.x, cornerPoint.y, scaledWidth, scaledHeight);
        [sourceImage drawInRect:resizeRect];
        
        UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
        if (resizedImage == nil) {
            NSLog(@"could not scale image");
        }
        UIGraphicsEndImageContext();
        
        return resizedImage;
    }
    return sourceImage;
}
                    
@end
