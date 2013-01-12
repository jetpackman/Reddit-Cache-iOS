//
//  MGDrawerViewController.h
//

#import <UIKit/UIKit.h>
#import "TWGMenuController.h"
#import "User.h"
#import "MyJournalViewController.h"

typedef enum {
    kPUSH,
    kSET_ROOT,
    kACTION_BLOCK,
} DrawerRowType;


@interface TWGDrawerViewController: UIViewController <TWGDrawerViewControllerProtocol, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) TWGMenuController *menuController;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *tableData;
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) UIImage *chevronImage;
@property (nonatomic, strong) UIColor *blueHeaderColour;


- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil user:(User*)user;
- (void)selectRow:(NSInteger)row;

@end
