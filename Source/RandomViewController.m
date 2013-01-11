//
//  RandomViewController.h
//  onething
//
//  Created by Dane Carr on 12-02-17.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import "RandomViewController.h"
#import "GratitudeTile.h"
#import "NSMutableArray+TWG.h"
#import "CalendarViewController.h"

@implementation RandomViewController

@synthesize scrollView = _scrollView;
@synthesize tempTile = _tempTile;
@synthesize user = _user;
@synthesize dateFormatter = _dateFormatter;
@synthesize updateOperation = _updateOperation;
@synthesize gratitudes = _gratitudes;
@synthesize previousScrollBounds = _previousScrollBounds;
@synthesize currentIndex = _currentIndex;
@synthesize indexedViews = _indexedViews;
@synthesize reusableViews = _reusableViews;
@synthesize loadingTileIndex = _loadingTileIndex;
@synthesize rightArrowImage = _rightArrowImage;
@synthesize leftArrowImage = _leftArrowImage;
@synthesize tapDismissGesture = _tapDismissGesture;
@synthesize createGratitudeButton = _createGratitudeButton;

#define SCROLLVIEW_WIDTH 320.0f
#define SCROLLVIEW_HEIGHT 372.0f
#define SCROLLVIEW_MARGIN 20.0f
#define TILE_WIDTH 310.0f
#define TILE_HEIGHT 332.0f
#define TILE_OFFSET 10.0f
#define TILE_BUFFER_SIZE 1
#define GRATITUDES_PER_REQUEST 25

#define ARROW_ALPHA 0.3

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureNavBar];

    [self.view setAccessibilityLabel:@"My History Screen"];

    self.pushedViewControllers = [NSMutableArray array];
    
    self.rightArrowImage.alpha = 0;
    self.leftArrowImage.alpha = 0;
    // Flip arrow instead of using separate image
    self.leftArrowImage.transform = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI);
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter  setDateStyle:NSDateFormatterLongStyle];
    [self.dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    self.previousScrollBounds = self.scrollView.bounds;
    
    self.indexedViews = [[NSMutableDictionary alloc] initWithCapacity:(TILE_BUFFER_SIZE*2) + 1];
    self.reusableViews = [[NSMutableArray alloc] init];
    self.loadingTileIndex = [[NSNumber alloc] initWithInt:-1];
    
    self.tapDismissGesture = [[UITapGestureRecognizer alloc] init];
    self.tapDismissGesture.delegate = self;
    [self.tapDismissGesture addTarget:self action:@selector(switchToDetailView)];
    [self.view addGestureRecognizer:self.tapDismissGesture];
    
    UISwipeGestureRecognizer *buttonSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(createGratitudeSwiped:)];
    buttonSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
    [self.createGratitudeButton addGestureRecognizer:buttonSwipeGestureRecognizer];
    

}

-(void)configureNavBar
{
    [self setTitle:@"Random Gratitude"];
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navbutton_calendar.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(showCalendar)];
    self.navigationItem.rightBarButtonItem = btn;
    [self.navigationItem.rightBarButtonItem setAccessibilityLabel:@"Calendar"];
}

- (void)showCalendar
{
    CalendarViewController *calendarViewController = [[CalendarViewController alloc] init];
    calendarViewController.user = self.user;
    
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle: @"Back" style: UIBarButtonItemStyleBordered target: nil action: nil];
    [[self navigationItem] setBackBarButtonItem: newBackButton];
    [self.navigationController pushViewController:calendarViewController animated:YES];
}

- (void) createGratitudeSwiped:(UIGestureRecognizer*)recognizer
{
    [self createGratitude:recognizer];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.pushedViewControllers removeAllObjects];
    if(self.gratitudes.count == 0){
        [self.tempTile removeFromSuperview];
        [self reloadGratitudes];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (GratitudeTile*)dequeueGratitudeTile {
    GratitudeTile *tile = nil;
    if (self.reusableViews.count == 0) {
        // Initialize a new tile if no reusable ones are available
        tile = [[GratitudeTile alloc] initWithFrame:CGRectMake(0, 0, TILE_WIDTH, TILE_HEIGHT)];
    }
    else {
        // Recycle a previously used tile
        tile = [self.reusableViews removeFirstObject];
    }
    [tile hideLoadingIndicator];
    return tile;
}

- (NSArray*)trimViews {
    // Trim views outside of buffer range
    NSMutableArray *outOfRangeViews = [[NSMutableArray alloc] init];
    NSMutableArray *outOfRangeKeys = [[NSMutableArray alloc] init];
    for (NSNumber *index in self.indexedViews) {
        if (abs(index.integerValue - self.currentIndex) > TILE_BUFFER_SIZE) {
            [outOfRangeViews addObject:[self.indexedViews objectForKey:index]];
            [outOfRangeKeys addObject:index];
            [[self.indexedViews objectForKey:index] removeFromSuperview];
        }
    }
    [self.indexedViews removeObjectsForKeys:outOfRangeKeys];
    
    return outOfRangeViews;
}

- (void)createTiles {
    // Create initial tiles
    NSInteger initialTileCount = MIN(self.gratitudes.count, TILE_BUFFER_SIZE + 1);
    self.currentIndex = 0;
    GratitudeTile *tile = nil;
    Gratitude *gratitude = nil;
    if(self.gratitudes.count == 0) {
        self.tempTile = [[GratitudeTile alloc] initWithFrame:CGRectMake(0, 0, TILE_WIDTH, TILE_HEIGHT)];
        self.tempTile.frame = CGRectMake(5, SCROLLVIEW_MARGIN, TILE_WIDTH, TILE_HEIGHT);
        
        [self.tempTile setBody:@"Please add gratitude before using this screen." createdAt:nil];
        
        [self.scrollView addSubview:self.tempTile];
    } else {
        for (int i = 0; i < initialTileCount; i++) {
            tile = [self dequeueGratitudeTile];
            tile.frame = CGRectMake((i * SCROLLVIEW_WIDTH) + 5, SCROLLVIEW_MARGIN, TILE_WIDTH, TILE_HEIGHT);
            gratitude = [self.gratitudes objectAtIndex:i];
            
            [tile setBody:gratitude.body createdAt:[self.dateFormatter stringFromDate:gratitude.createdAt]];
            
            [self.scrollView addSubview:tile];
            [self.indexedViews setObject:tile forKey:[NSNumber numberWithInt:i]];
        }
    }
}

#pragma mark - Gratitudes

- (void)reloadGratitudes{
    // Only one update operation at a time
    if (self.updateOperation) {
        return;
    }
    
    // Create loading tile
    GratitudeTile *loadingTile = [[GratitudeTile alloc] initWithFrame:CGRectMake(0, 0, TILE_WIDTH, TILE_HEIGHT)];
    [loadingTile setFrame:CGRectMake(5, SCROLLVIEW_MARGIN, TILE_WIDTH, TILE_HEIGHT)];
    [loadingTile showLoadingIndicator];
    self.scrollView.contentSize = CGSizeMake(TILE_WIDTH, TILE_HEIGHT);
    [self.scrollView addSubview:loadingTile];
    
    
    // Initial gratitude population
    [[OnethingClientAPI sharedClient] randomGratitudesWithApiKey:self.user.apiKey 
                                                         perPage:GRATITUDES_PER_REQUEST 
                                                         startup:^(NSOperation *operation) {
                                                             self.updateOperation = operation;
                                                         } 
                                                         success:^(NSArray *gratitudes, int count) {
                                                             [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                                                 [loadingTile hideLoadingIndicator];
                                                                 [loadingTile removeFromSuperview];
                                                                 [self.reusableViews addObject:loadingTile];
                                                                 //self.loadingTile = nil;
                                                                 
                                                                 self.gratitudes = [NSMutableArray arrayWithArray:gratitudes];
                                                                 [self createTiles];
                                                                 self.scrollView.contentSize = CGSizeMake(self.gratitudes.count * SCROLLVIEW_WIDTH, self.scrollView.contentSize.height);
                                                                 [self showArrows];
                                                             }];
                                                         } 
                                                         failure:^(NSHTTPURLResponse *response, NSError *error) {
                                                             NSLog(@"[ERROR] Failed to load gratitudes: %@ %@", [response debugDescription], [error userInfo]);
                                                         } 
                                                      completion:^{
                                                          self.updateOperation = nil;
                                                      }];
    

}

- (void)loadGratitudes{
    // Only one update operation at a time
    if (self.updateOperation) {
        return;
    }

    // Create the operation
    [[OnethingClientAPI sharedClient] randomGratitudesWithApiKey:self.user.apiKey 
                                                         perPage:GRATITUDES_PER_REQUEST 
                                                         startup:^(NSOperation *operation) {
                                                             self.updateOperation = operation;
                                                         }
                                                         success:^(NSArray *gratitudes, int count) {
                                                             [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                                                 
                                                                 [self.gratitudes addObjectsFromArray:gratitudes];
                                                                 
                                                                 self.scrollView.contentSize = CGSizeMake(self.gratitudes.count* SCROLLVIEW_WIDTH, self.scrollView.contentSize.height);
                                                                 [self showArrows];
                                                                 
                                                                 if ([self.indexedViews objectForKey:self.loadingTileIndex]) {
                                                                     // If loading tile is in the buffer, update it with loaded gratitude
                                                                     GratitudeTile *tile = [self.indexedViews objectForKey:self.loadingTileIndex];
                                                                     Gratitude *gratitude = [self.gratitudes objectAtIndex:self.loadingTileIndex.intValue];
                                                                     
                                                                     [tile setBody:gratitude.body createdAt:[self.dateFormatter stringFromDate:gratitude.createdAt]];
                                                                     
                                                                     [tile hideLoadingIndicator];
                                                                     int tileIndex = 0;
                                                                     
                                                                     for (int i = 1; i <= TILE_BUFFER_SIZE - (self.loadingTileIndex.intValue - self.currentIndex); i++) {
                                                                         //Draw some tiles to fill the tile buffer
                                                                         tileIndex = self.loadingTileIndex.intValue+ i;
                                                                         GratitudeTile *tile = [self dequeueGratitudeTile];
                                                                         tile.frame = CGRectMake(SCROLLVIEW_WIDTH * tileIndex + 5, SCROLLVIEW_MARGIN, TILE_WIDTH, TILE_HEIGHT);
                                                                         
                                                                         Gratitude *gratitude = [self.gratitudes objectAtIndex:tileIndex];
                                                                         
                                                                         [tile setBody:gratitude.body createdAt:[self.dateFormatter stringFromDate:gratitude.createdAt]];
                                                                         
                                                                         [self.scrollView addSubview:tile];
                                                                         [self.indexedViews setObject:tile forKey:[NSNumber numberWithInteger:tileIndex]];
                                                                     }
                                                                 }
                                                             }];
                                                         } 
                                                         failure:^(NSHTTPURLResponse *response, NSError *error) {
                                                             NSLog(@"[ERROR] Failed to load gratitudes: %@ %@", [response debugDescription], [error userInfo]);
                                                         } 
                                                      completion:^{
                                                          self.updateOperation = nil;
                                                      }];
}

#pragma mark - Actions
- (IBAction)createGratitude:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:CreatingGratitudeNotification object:nil];
}

- (IBAction)scrollLeft:(id)sender {
    [self hideArrows];
    [self scrollTilesInScrollView:self.scrollView direction:LeftScrollDirection];
    [self.scrollView scrollRectToVisible:CGRectMake(SCROLLVIEW_WIDTH * self.currentIndex + 5, SCROLLVIEW_MARGIN, TILE_WIDTH, TILE_HEIGHT) animated:YES];
    [self showArrows];
}

- (IBAction)scrollRight:(id)sender {
    [self hideArrows];
    [self scrollTilesInScrollView:self.scrollView direction:RightScrollDirection];
    [self.scrollView scrollRectToVisible:CGRectMake(SCROLLVIEW_WIDTH * self.currentIndex + 5, SCROLLVIEW_MARGIN, TILE_WIDTH, TILE_HEIGHT) animated:YES];
    [self showArrows];
}

- (void)scrollTilesInScrollView:(UIScrollView *)scrollView direction:(ScrollDirection)direction {
    if (self.gratitudes.count == 0) {
        return;
    }
    
    // +1 for right, -1 for left
    self.currentIndex += direction;
    // Trim unused views and store for future use
    [self.reusableViews addObjectsFromArray:[self trimViews]];
    
    if (self.currentIndex < TILE_BUFFER_SIZE && direction == LeftScrollDirection) {
        // No tiles are needed to the left of the first one
        return;
    }
    
    // Index for the tile being created
    NSInteger tileIndex = self.currentIndex + (direction * TILE_BUFFER_SIZE);
    if (tileIndex > self.gratitudes.count - TILE_BUFFER_SIZE) {
        [self loadGratitudes];
    }
    
    if (self.currentIndex > self.gratitudes.count - TILE_BUFFER_SIZE && direction == RightScrollDirection) {
        // No tiles are needed to the right of the last one
        return;
    }
    
    // Get a tile and position it
    GratitudeTile *tile = [self dequeueGratitudeTile];
    tile.frame = CGRectMake(SCROLLVIEW_WIDTH * tileIndex + 5, SCROLLVIEW_MARGIN, TILE_WIDTH, TILE_HEIGHT);
    
    // Show loading indicator if waiting on network request
    if (tileIndex > self.gratitudes.count - 1) {        
        [tile showLoadingIndicator];
        self.loadingTileIndex = [NSNumber numberWithInt:tileIndex];
    }
    else {
        // Get gratitude and configure tile with it
        Gratitude *gratitude = [self.gratitudes objectAtIndex:tileIndex];
        [tile setBody:gratitude.body createdAt:[self.dateFormatter stringFromDate:gratitude.createdAt]];
    }

    // Add tile to scrollview
    [scrollView addSubview:tile];
    // Keep track of tiles in use
    [self.indexedViews setObject:tile forKey:[NSNumber numberWithInteger:tileIndex]];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (CGRectGetMinX(scrollView.bounds) == CGRectGetMinX(self.previousScrollBounds)) {
        // No scroll occurred
        [self showArrows];
        return;
    }
    else if (CGRectGetMinX(scrollView.bounds) > CGRectGetMinX(self.previousScrollBounds)) {
        // Scrolled right
        self.previousScrollBounds = scrollView.bounds;
        [self scrollTilesInScrollView:scrollView direction:RightScrollDirection];
    }
    else {
        // Scrolled left
        self.previousScrollBounds = scrollView.bounds;
        [self scrollTilesInScrollView:scrollView direction:LeftScrollDirection];
    }
    [self showArrows];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (abs(CGRectGetMinX(scrollView.bounds) - CGRectGetMinX(self.previousScrollBounds)) > SCROLLVIEW_WIDTH) {
        if (CGRectGetMinX(scrollView.bounds) > CGRectGetMinX(self.previousScrollBounds)) {
            // Scrolled right
            self.previousScrollBounds = CGRectMake((self.currentIndex+1) * SCROLLVIEW_WIDTH, 0, SCROLLVIEW_WIDTH, SCROLLVIEW_HEIGHT);
            [self scrollTilesInScrollView:scrollView direction:RightScrollDirection];
        }
        else {
            // Scrolled left
            self.previousScrollBounds = CGRectMake((self.currentIndex-1) * SCROLLVIEW_WIDTH, 0, SCROLLVIEW_WIDTH, SCROLLVIEW_HEIGHT);
            [self scrollTilesInScrollView:scrollView direction:LeftScrollDirection];
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    // Hide arrows when user drags scrollview
    [self hideArrows];
}

- (void)hideArrows {
    [UIView animateWithDuration:0.3 delay:0 options:(UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionOverrideInheritedDuration) animations:^{
        self.rightArrowImage.alpha = 0;
        self.leftArrowImage.alpha = 0;
    } completion:nil];
}

- (void)showArrows {
    if (self.gratitudes.count <= 1) {
        return;
    }
    
    CGFloat duration = 0.5;
    CGFloat delay = 1;
    
    if (self.currentIndex == 0) {
        // Only show right arrow
        [UIView animateWithDuration:duration delay:delay options:(UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionOverrideInheritedDuration) animations:^{
            self.rightArrowImage.alpha = ARROW_ALPHA;
        } completion:nil];
    }
    else if (self.currentIndex == self.gratitudes.count) {
        // Don't show arrows on loading tile
        return;
    }
    else {
        // Show both arrows
        [UIView animateWithDuration:duration delay:delay options:(UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionOverrideInheritedDuration) animations:^{
            self.rightArrowImage.alpha = ARROW_ALPHA;
            self.leftArrowImage.alpha = ARROW_ALPHA;
        } completion:nil];
    }
}

#pragma mark - Gesture Management
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch 
{    
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        CGPoint touchPoint = [touch locationInView:self.view];
        if(touchPoint.x > 50 && touchPoint.x < 270 &&
           touchPoint.y > 50 && touchPoint.y < 350){
            return YES;
        }
    }
    return NO;
}

- (void) switchToDetailView {
    Gratitude* gratitude  = [self.gratitudes objectAtIndex:self.currentIndex];
    // Create and show view controller
    DetailRandomGratitudeViewController *viewController = [[DetailRandomGratitudeViewController alloc] init];
    viewController.user = self.user;
    viewController.gratitude = gratitude;
    
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle: @"Back" style: UIBarButtonItemStyleBordered target: nil action: nil];
    [[self navigationItem] setBackBarButtonItem: newBackButton];
    
    [self.pushedViewControllers addObject:viewController];
    [self.navigationController pushViewController:viewController animated:YES];

}


- (void)viewDidUnload {
    [self setCreateGratitudeButton:nil];
    [super viewDidUnload];
}
@end
