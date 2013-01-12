//
//  TWGAlertView.h
//  twg-helpers-ios
//
//  Created by Jeremy Bower on 11-11-01.
//  Copyright (c) 2011 The Working Group Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^TWGAlertBlock)();

@interface TWGAlertItem : NSObject 
    
@property (nonatomic, strong) NSString* title;
@property (nonatomic, copy) TWGAlertBlock block;

+ (TWGAlertItem*)alertItemWithTitle:(NSString*)title;

+ (TWGAlertItem*)alertItemWithTitle:(NSString*)title block:(TWGAlertBlock)block;

- (id)initWithTitle:(NSString*)title block:(TWGAlertBlock)block;
    
@end

@interface TWGAlertView : UIAlertView <UIAlertViewDelegate>

@property (nonatomic, retain) NSArray* items;

+ (TWGAlertView*)alertViewWithTitle:(NSString *)title 
                            message:(NSString *)message 
                         cancelItem:(TWGAlertItem*)cancelItem
                         otherItems:(NSArray*)otherItems;

+ (TWGAlertView*)alertViewWithTitle:(NSString *)title 
                            message:(NSString *)message
                          itemTitle:(NSString *)itemTitle
                          itemBlock:(TWGAlertBlock)itemBlock;

+ (void)showAlertViewWithTitle:(NSString *)title 
                       message:(NSString *)message
                     itemTitle:(NSString *)itemTitle
                     itemBlock:(TWGAlertBlock)itemBlock;

+ (void)showAlertViewWithTitle:(NSString *)title 
                       message:(NSString *)message 
                    cancelItem:(TWGAlertItem*)cancelItem
                    otherItems:(NSArray*)otherItems;

- (id)initWithTitle:(NSString *)title 
            message:(NSString *)message 
         cancelItem:(TWGAlertItem*)cancelItem
         otherItems:(NSArray*)otherItems;

@end
