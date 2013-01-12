//
//  MGDrawerViewController.m
//

#import "TWGDrawerViewController.h"
#import "TWGMenuController.h"
#import "CalendarViewController.h"
#import "RandomViewController.h"
#import "SettingsViewController.h"
#import "PublicJournalViewController.h"
#import "TopWordsViewController.h"
#import "GratitudeMapViewController.h"
#import "WordCloudViewController.h"
#import "SignUpViewController.h"
#import "IllustrationViewController.h"

@implementation TWGDrawerViewController

@synthesize menuController = _menuController; 
@synthesize tableData = _tableData;
@synthesize tableView = _tableView;
@synthesize drawerView = _drawerView;
@synthesize chevronImage = _chevronImage;
@synthesize user = _user;
@synthesize blueHeaderColour = _blueHeaderColour;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil user:(User*)user
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.user = user;
        self.blueHeaderColour = [UIColor colorWithRed:54.0/255.0 green:75.0/255.0 blue:104.0/255.0 alpha:1];
        
        self.chevronImage = [UIImage imageNamed:@"table_chevron.png"];
        
        self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [self.tableView setSeparatorColor:[UIColor tableSeparatorColour]];
        [self.tableView setBackgroundColor:[UIColor clearColor]];
        [self.tableView setDelegate:self];
        [self.tableView setDataSource:self];
//        [self.tableView setScrollEnabled:NO];
        
        
        [self.view addSubview:self.tableView];
        [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_tile.png"]]];
        
        // Removes table separators on empty cells
        self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        
        MyJournalViewController *myJournalViewController = [[MyJournalViewController alloc] init];
        myJournalViewController.user = self.user;
        
        PublicJournalViewController *publicJournalViewController = [[PublicJournalViewController alloc] init];
        publicJournalViewController.user = self.user;
        
        GratitudeMapViewController *gratitudeMapViewController = [[GratitudeMapViewController alloc] init];
        gratitudeMapViewController.user = self.user;
        
        CalendarViewController *calendarViewController = [[CalendarViewController alloc] init];
        calendarViewController.user = self.user;
        
        TopWordsViewController *topWordsViewController = [[TopWordsViewController alloc] init];
        topWordsViewController.user = self.user;
        
        WordCloudViewController *wordCloudViewController = [[WordCloudViewController alloc] init];
        wordCloudViewController.user = self.user;
        
        RandomViewController *randomViewController = [[RandomViewController alloc] init];
        randomViewController.user = self.user;
        
        SettingsViewController *settingsViewController = [[SettingsViewController alloc] init];
        settingsViewController.user = self.user;
        
        IllustrationViewController *illustrationViewController = [[IllustrationViewController alloc] init];

        
        /*
         tableData has this format:
         NSArray                //Container Array
            NSArray             //Represents a Section of the table
                NSDictionary    //Represents a Row of the table, in the given section
                NSDictionary    //keys: label (title displayed), rowType (one of enum DrawerRowType), object (parameter)
            NSArray
         ...
         */
        self.tableData = [[NSMutableArray alloc] initWithObjects:
                          
                          // Personal Gratitude section
                          [[NSMutableArray alloc] initWithObjects:
                           [NSDictionary dictionaryWithObjectsAndKeys:@"My Journal", @"title", [UIImage imageNamed:@"icon_my_gratitude.png"], @"icon", [NSNumber numberWithInt:kSET_ROOT], @"rowType", myJournalViewController, @"object", nil],
                           [NSDictionary dictionaryWithObjectsAndKeys:@"My Trends", @"title", [UIImage imageNamed:@"icon_top_words.png"], @"icon", [NSNumber numberWithInt:kSET_ROOT], @"rowType", topWordsViewController, @"object", nil],
                           [NSDictionary dictionaryWithObjectsAndKeys:@"My History", @"title", [UIImage imageNamed:@"icon_random.png"], @"icon", [NSNumber numberWithInt:kSET_ROOT], @"rowType", randomViewController, @"object", nil],
                           nil],
                          
                          // Community Gratitude section
                          [[NSMutableArray alloc] initWithObjects:
                           [NSDictionary dictionaryWithObjectsAndKeys:@"Public Journal", @"title", [UIImage imageNamed:@"icon_public_journal.png"], @"icon", [NSNumber numberWithInt:kSET_ROOT], @"rowType", publicJournalViewController, @"object", nil],
                           [NSDictionary dictionaryWithObjectsAndKeys:@"Illustrated", @"title", [UIImage imageNamed:@"icon_illustrated.png"], @"icon", [NSNumber numberWithInt:kSET_ROOT], @"rowType", illustrationViewController, @"object", nil],
                           
//                           [NSDictionary dictionaryWithObjectsAndKeys:@"Gratitude Map", @"title", [UIImage imageNamed:@"icon_map_marker.png"], @"icon", [NSNumber numberWithInt:kSET_ROOT], @"rowType", gratitudeMapViewController, @"object", nil],
                           nil],

//                          // Reflections section
//                          [[NSMutableArray alloc] initWithObjects:
//                           
//                           [NSDictionary dictionaryWithObjectsAndKeys:@"Word Cloud", @"title", [UIImage imageNamed:@"icon_word_cloud.png"], @"icon", [NSNumber numberWithInt:kSET_ROOT], @"rowType", wordCloudViewController, @"object", nil],
//                           [NSDictionary dictionaryWithObjectsAndKeys:@"Random", @"title", [UIImage imageNamed:@"icon_random.png"], @"icon", [NSNumber numberWithInt:kSET_ROOT], @"rowType", randomGratitudeViewController, @"object", nil], 
//                           nil],
//                           
                          // Settings section
                          [[NSMutableArray alloc] initWithObjects:
                           [NSDictionary dictionaryWithObjectsAndKeys:@"Settings", @"title", [UIImage imageNamed:@"icon_settings.png"], @"icon", [NSNumber numberWithInt:kSET_ROOT], @"rowType", settingsViewController, @"object", nil],
                           nil],
                          nil];        
    }
    return self;
}

- (void) viewDidLoad 
{
    // This is the notification that is fired from a LocalNotification from iOS.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(creatingGratitude:) name:CreateGratitudeNotification object:nil];
    
    // This is for when you finish creating a gratitude: used for bouncing the user back to my gratitudes screen.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(creatingGratitude:) name:CreatingGratitudeNotification object:nil];
}

- (void) viewWillUnload:(BOOL)animated 
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)creatingGratitude:(id)sender 
{
    // Save the old root viewcontroler
    BaseViewController* oldRoot = (BaseViewController*) self.menuController.rootViewController;
    CreateGratitudeViewController *viewController = [[CreateGratitudeViewController alloc] init];
    viewController.user = self.user;
    
    viewController.createGratitudeCallback = ^(Gratitude *gratitude) {
        [self.myGratitudeViewController gratitudeCreatedCallback:gratitude];
    };
    
    viewController.animationCompleteCallback = ^{
        [self.menuController changeRootViewController:self.myGratitudeViewController animated:NO];

    };
    
    viewController.canceledGratitudeCallback = ^{
        [self.menuController changeRootViewController:oldRoot animated:NO];
    };
    
    [viewController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    
    // Dismiss any open modals currently
    BOOL dismissModals = NO;
    NSMutableArray* pushedViewControllers = [oldRoot pushedViewControllers];
    if (oldRoot.modalDisplayed) {
        dismissModals = YES;
    }
    else if ([pushedViewControllers count]) {
        for (BaseViewController* vc in pushedViewControllers) {
            if (vc.modalDisplayed) {
                dismissModals = YES;
                break;
            }
        }
    }
    if (dismissModals) {
        [oldRoot dismissViewControllerAnimated:NO completion:nil];
    }
    oldRoot.modalDisplayed = YES;

    [oldRoot presentViewController:viewController animated:YES completion:nil];
    
    
//    double delayInSeconds = 0.6f;
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//        oldRoot.modalDisplayed = YES;
//        [oldRoot presentModalViewController:viewController animated:YES];  
//    });

}

- (void)loadView 
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];//[[UIScreen mainScreen] bounds]];
    [view setBackgroundColor:[UIColor tableBackgroundColour]];
    
    self.drawerView = self.tableView;
    
    [view addSubview:self.tableView];
    [self setView:view];
}

- (void)viewWillAppear:(BOOL)animated 
{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO]; 
}

- (MyJournalViewController*)myGratitudeViewController 
{
    MyJournalViewController* vc = (MyJournalViewController*) [[[self.tableData objectAtIndex:0] objectAtIndex:0] objectForKey:@"object"];
    return vc;
}

- (void)viewDidUnload 
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}

- (void)selectRow:(NSInteger)row 
{
    NSDictionary *currentRow = [[self.tableData objectAtIndex:0] objectAtIndex:row];
    DrawerRowType rowType = [[currentRow objectForKey:@"rowType"] intValue];
    
    if (rowType == kPUSH) {
        [self.menuController pushViewController:[currentRow objectForKey:@"object"]];
    }
    else if (rowType == kSET_ROOT) {
        [self.menuController changeRootViewController:[currentRow objectForKey:@"object"] animated:NO];
    }
}


#pragma mark - TableView Delegate
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if (self.menuController.animating){
        return nil;
    }    
    return indexPath;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSDictionary *currentRow = [[self.tableData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    DrawerRowType rowType = [[currentRow objectForKey:@"rowType"] intValue];
    
    if (rowType == kPUSH) {
        [self.menuController pushViewController:[currentRow objectForKey:@"object"]];
    } else if (rowType == kSET_ROOT) {
        [self.menuController changeRootViewController:[currentRow objectForKey:@"object"] animated:YES];
    } else if (rowType == kACTION_BLOCK) {
        void (^actionBlock)() = [currentRow objectForKey:@"object"];
        actionBlock();
    }
}


#pragma mark - TableView Datasource

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section 
{
    return [[self.tableData objectAtIndex:section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    return 44.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *CellIdentifier = @"Cell";
    
    // Acquire the cell. 
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
        
        // Using the selection color here as BG on purpose
        UIView *backgroundView = [[UIView alloc] init];
        [backgroundView setBackgroundColor:[UIColor tableSelectionColour]];
        [cell setBackgroundView:backgroundView];
        
        UIView *selectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
        [selectionView setBackgroundColor:[UIColor tableBackgroundColour]];
        UIImageView *insideShadowView = [[UIImageView alloc] initWithFrame:selectionView.frame];
        insideShadowView.image = [[UIImage imageNamed:@"bg_inside_shadow.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(4, 4, 4, 4)];
        insideShadowView.alpha = 0.5;
        [selectionView addSubview:insideShadowView];
        
        [cell setSelectedBackgroundView:selectionView];
        
        [cell.textLabel setBackgroundColor:[UIColor clearColor]];
        [cell.textLabel setOpaque:NO];
        cell.textLabel.textColor = [UIColor tableTextColour];
        cell.textLabel.highlightedTextColor = [UIColor tableTextColour];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:self.chevronImage];
        imageView.tag = indexPath.row;
        
        if (self.menuController.leftDrawer == self) {
            imageView.frame = CGRectMake(self.menuController.leftDrawerWidth - imageView.image.size.width - 10, ([self tableView:tableView heightForRowAtIndexPath:indexPath] - imageView.image.size.height) * 0.5, imageView.image.size.width, imageView.image.size.height);        
        }
        else {
            imageView.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - imageView.image.size.width - 10, ([self tableView:tableView heightForRowAtIndexPath:indexPath] - imageView.image.size.height) * 0.5, imageView.image.size.width, imageView.image.size.height);        
        }
        
        [cell addSubview:imageView];
        
        // Set indentation level for right drawer
        cell.indentationWidth = [UIScreen mainScreen].bounds.size.width - self.menuController.rightDrawerWidth + 10;
    }
    
    // Indent cell for right drawer
    if (self.menuController.leftDrawer == self) {
        cell.indentationLevel = 0;
    }
    else if (self.menuController.rightDrawer == self) {
        cell.indentationLevel = 1;
    }
    
    cell.textLabel.text = [[[self.tableData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"title"];
    [cell.imageView setImage:[[[self.tableData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"icon"]];
    [cell setAccessibilityLabel:cell.textLabel.text];
    DrawerRowType rowType = [[[[self.tableData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"rowType"] intValue];
    if (rowType == kACTION_BLOCK) {
        [[cell.contentView viewWithTag:indexPath.row] setHidden:YES];
    } else {
        [[cell.contentView viewWithTag:indexPath.row] setHidden:NO];
    }
    return cell;
}



- (UIView *) tableView:(UITableView *)aTableView viewForHeaderInSection:(NSInteger)section 
{
    UIView* customView = [[UIView alloc] init];
    if (self.menuController.leftDrawer == self) {
        customView.frame = CGRectMake(7, 0, [[UIScreen mainScreen] bounds].size.width, [self tableView:self.tableView heightForHeaderInSection:section]);
    }
    else {
        customView.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - self.menuController.rightDrawerWidth + 15, 0, [UIScreen mainScreen].bounds.size.width, [self tableView:self.tableView heightForHeaderInSection:section]);
    }
    
    customView.backgroundColor = self.blueHeaderColour;
    
    UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.opaque = NO;
    headerLabel.textColor = [UIColor whiteColor];
    headerLabel.font = [UIFont boldSystemFontOfSize:12];
    if (self.menuController.leftDrawer == self) {
        headerLabel.frame = CGRectMake(8, 0, customView.frame.size.width, customView.frame.size.height);
    }
    else {
        headerLabel.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - self.menuController.rightDrawerWidth + 16, 0, customView.frame.size.width, customView.frame.size.height);
    }
    headerLabel.textAlignment = NSTextAlignmentLeft;
    headerLabel.text = [self tableView:aTableView titleForHeaderInSection:section];
    [customView addSubview:headerLabel];
    return customView;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section 
{    
    if (section < 2) {
        return 24.0;
    }
    return 5.f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return [self.tableData count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{    
    switch (section) {
        case 0:
            return @"Personal Gratitude";
            break;
        case 1:
            return @"Community Gratitude";
            break;
        case 2:
            return @"";
            break;
        default:
            return @"1Thing";
            break;
    }
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath 
{
    return NO;
}

- (void)logout:(id)sender 
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:NO forKey:UserDefaultsLoggedIn];
    [defaults synchronize];
    [self.menuController.presentingViewController dismissViewControllerAnimated:YES completion:nil];

}

- (void)signup:(id)sender
{
    // Show signup screen
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:NO forKey:UserDefaultsLoggedIn];
    [defaults synchronize];
    
    SignUpViewController *viewController = [[SignUpViewController alloc] initWithNibName:@"SignUpViewController" bundle:nil];
    [self presentModalViewController:viewController navigation:NO animated:YES];
}

#pragma mark - Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
