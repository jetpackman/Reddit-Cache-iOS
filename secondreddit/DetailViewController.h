//
//  DetailViewController.h
//  secondreddit
//
//  Created by Aaron Lee on 2013-01-11.
//  Copyright (c) 2013 Aaron Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
