//
//  TWGMenuController.h
//

#import <UIKit/UIKit.h>

typedef enum {
    kSHOW_RIGHT,
    kSHOW_LEFT,
    kHIDE_RIGHT,
    kHIDE_LEFT
} SlideDirection;

@protocol TWGDrawerViewControllerProtocol;


//==============================
// TWGMenuController Interface
//==============================

@interface TWGMenuController : UIViewController <UINavigationControllerDelegate, UIGestureRecognizerDelegate>

#pragma mark - Initializers

- (id)initWithLeftDrawer:(UIViewController<TWGDrawerViewControllerProtocol> *) leftDrawer RightDrawer:(UIViewController<TWGDrawerViewControllerProtocol> *) rightDrawer andRootViewController:(UIViewController *) viewController;

#pragma mark - TWGMenu Settings

- (void) hideDefaultNavigationBarButtons:(BOOL)hideNavButtons;


#pragma mark - Drawer API

@property (nonatomic, strong) UIViewController<TWGDrawerViewControllerProtocol> *leftDrawer;
@property (nonatomic, strong) UIViewController<TWGDrawerViewControllerProtocol> *rightDrawer;
@property (nonatomic, strong) UIViewController *rootViewController;

@property (nonatomic, assign) NSInteger rightDrawerWidth;
@property (nonatomic, assign) NSInteger leftDrawerWidth;
@property (nonatomic, assign) BOOL animating;


/** Manually show right or left drawer */
- (void) showRightDrawer;
- (void) showLeftDrawer;

/** Manually dismiss right or left drawer */
- (void) dismissRightDrawer;
- (void) dismissLeftDrawer;
/** Manually dismiss any visible drawer */
- (void) dismissVisibleDrawer;

- (void)addLeftDrawer:(UIViewController<TWGDrawerViewControllerProtocol> *)drawerViewController;
- (void) addRightDrawer:(UIViewController<TWGDrawerViewControllerProtocol> *)drawerViewController; 
#pragma mark - Container API

/** Push view controller on navigation stack. This method needs to be used to push a view controller from a side drawer. The drawer will
 not be dismissed and the animation will not be right */
- (void) pushViewController:(UIViewController *) viewController;

/** Set the rootViewController. Not recommended to be used from a sde drawer view controlle since there is no animation */
- (void) changeRootViewController:(UIViewController *) viewController;

/** Set the rootViewController and perform animation. Should be used from the side drawer view controller */
- (void) changeRootViewController:(UIViewController *) viewController animated:(BOOL)animated;
- (void) setCurrentRootViewController:(UIViewController *)rootViewController;


@end


//=================================
// TWGDrawerViewControllerProtocol
//=================================
/**
 The protocol should be implemented by drawers you create. The drawerView property is the only required part of this 
 protocol. It should represent the view of the drawer itself. This drawerView should be a subview of the view controllers
 full view which should take up the full 320x480. This is because the animation for the setRootViewController: method
 fills the entire screen with the drawer.
 
 eg. In your UIViewController you would set a its view as a new UIView with a frame of CGRectMake(0,0,320,480). You would then
 add a UITableView with a frame of CGRectMake(0,0,250,480) as a subview and save a reference to the tableView in the 
 drawerView property.
 */
@protocol TWGDrawerViewControllerProtocol
@required
/** A reference to the view of the drawer itself. This should be a subview of a view that is 320x480 */
@property (nonatomic, strong) UIView *drawerView;
@property (nonatomic, weak) TWGMenuController *menuController;

@end


//================================
// TWGRootViewControllerProtocol
//================================
/**
 (OPTIONAL) You can use this protocol on a UIViewController that will be set as the root of the MenuController in order to 
 override the displayed drawers. This is useful for cases where you want one of the drawers to be different based on the selected
 root. (e.g. In the Path 2.0 app, the right drawer is constant and is used to changed the root view controller, while the left
 is only present for a few view controllers. To accomplish this, you would set only a right drawer in the MenuController itself
 and use this protocol to return a value in the "leftDrawerForMenuController:" method in the ViewControllers where you want a
 leftDrawer to be displayed. This also allows you to have custom drawer based on the chosen root view controller)
 
 It is optional to use this protocol, you may set any UIViewController as root in the TWGMenuController, it does not NEED to 
 implement this protocol.
 
 It is not recommended to implement both of these methods. It would be confusing for a user if both drawers changed every time the
 root view controller changed. It is preferable to use 1 drawer to change the root (like a tabbar controller, always changing the 
 "section" of the app), and the other drawer for options specific to the selected root view controller. It is for these root
 specific options that this protocol comes in handy
 */
@protocol TWGRootViewControllerProtocol
@optional

/* Override the indicated drawer for the given view controller. While the implementing UIViewController is displayed as root
 in the MenuController, the drawer will appear. When a different root view controller is selected, the drawer will revert to
 the default one specified by the TWGMenuController leftDrawer/rightDrawer properties. (if none have been specified for that
 given side, no drawer will be displayed on that side*/

- (UIViewController<TWGDrawerViewControllerProtocol> *) leftDrawerForMenuController:(TWGMenuController *) menuController;
- (UIViewController<TWGDrawerViewControllerProtocol> *) rightDrawerForMenuController:(TWGMenuController *) menuController;

@end


