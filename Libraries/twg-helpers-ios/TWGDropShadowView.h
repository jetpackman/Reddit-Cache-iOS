//
//  TWGDropShadowView.h
//

#import <UIKit/UIKit.h>

typedef enum {
    kLEFT,
    kRIGHT,
    kDOWN,
    kUP
} ShadowDirection;

@interface TWGDropShadowView : UIView

-(void) setShadowDirection:(ShadowDirection) direction;

@end
