//
//  RandomViewController.h
//  onething
//
//  Created by Dane Carr on 12-02-17.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "CreateGratitudeViewController.h"
#import "GratitudeTile.h"
#import "BaseViewController.h"
#import "DetailRandomGratitudeViewController.h"

@interface RandomViewController : BaseViewController <UIScrollViewDelegate, UIGestureRecognizerDelegate>

typedef enum {
    RightScrollDirection = 1,
    LeftScrollDirection = -1
} ScrollDirection;

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) GratitudeTile *tempTile;
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSOperation *updateOperation;
@property (nonatomic, strong) NSMutableArray *gratitudes;
@property (nonatomic, assign) CGRect previousScrollBounds;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) NSMutableDictionary *indexedViews;
@property (nonatomic, strong) NSMutableArray *reusableViews;
@property (nonatomic, strong) NSNumber *loadingTileIndex;
@property (nonatomic, weak) IBOutlet UIButton *rightArrowImage;
@property (nonatomic, weak) IBOutlet UIButton *leftArrowImage;
@property (nonatomic, strong) UIGestureRecognizer *tapDismissGesture;
@property (weak, nonatomic) IBOutlet UIButton *createGratitudeButton;


- (IBAction)createGratitude:(id)sender;
- (void)loadGratitudes;
- (void)createTiles;
- (NSArray*)trimViews;
- (GratitudeTile*)dequeueGratitudeTile;
- (void)scrollTilesInScrollView:(UIScrollView*)scrollView direction:(ScrollDirection)direction;
- (void)hideArrows;
- (void)showArrows;
- (void)switchToDetailView;

@end
