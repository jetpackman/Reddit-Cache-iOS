//
//  TWGAlertView.m
//  The Working Group
//
//  Created by Jeremy Bower on 11-11-01.
//  Copyright (c) 2011 The Working Group. All rights reserved.
//

#import "TWGAlertView.h"

@implementation TWGAlertItem

@synthesize title = _title;
@synthesize block = _block;

+ (TWGAlertItem*)alertItemWithTitle:(NSString*)title
{
    return [TWGAlertItem alertItemWithTitle:title block:nil];
}

+ (TWGAlertItem*)alertItemWithTitle:(NSString*)title block:(TWGAlertBlock)block
{
    return [[TWGAlertItem alloc] initWithTitle:title block:block];
}

- (id)initWithTitle:(NSString*)title block:(TWGAlertBlock)block
{
    self = [super init];
    if (self) {
        self.title = title;
        self.block = block;
    }
    
    return self;
}

@end

@implementation TWGAlertView

@synthesize items = _items;

#pragma mark - Create and return a TWGAlertView

+ (TWGAlertView*)alertViewWithTitle:(NSString *)title 
                            message:(NSString *)message
                          itemTitle:(NSString *)itemTitle
                          itemBlock:(TWGAlertBlock)itemBlock
{
    return [TWGAlertView alertViewWithTitle:title 
                                    message:message
                                 cancelItem:nil
                                 otherItems:[NSArray arrayWithObject:[TWGAlertItem alertItemWithTitle:itemTitle 
                                                                                                block:itemBlock]]];
}

+ (TWGAlertView*)alertViewWithTitle:(NSString *)title 
                            message:(NSString *)message 
                         cancelItem:(TWGAlertItem*)cancelItem
                         otherItems:(NSArray*)otherItems
{
    return [[TWGAlertView alloc] initWithTitle:title message:message cancelItem:cancelItem otherItems:otherItems];
}

#pragma mark - Create and show a TWGAlertView

+ (void)showAlertViewWithTitle:(NSString *)title 
                       message:(NSString *)message
                     itemTitle:(NSString *)itemTitle
                     itemBlock:(TWGAlertBlock)itemBlock
{
    [[TWGAlertView alertViewWithTitle:title message:message itemTitle:itemTitle itemBlock:itemBlock] show];
}

+ (void)showAlertViewWithTitle:(NSString *)title 
                       message:(NSString *)message 
                    cancelItem:(TWGAlertItem*)cancelItem
                    otherItems:(NSArray*)otherItems
{
    [[TWGAlertView alertViewWithTitle:title message:message cancelItem:cancelItem otherItems:otherItems] show];
}

#pragma mark - Initialization

- (id)initWithTitle:(NSString *)title message:(NSString *)message cancelItem:(TWGAlertItem*)cancelItem otherItems:(NSArray*)otherItems
{
    self = [super initWithTitle:title message:message delegate:self cancelButtonTitle:cancelItem.title otherButtonTitles:nil];
    if (self) {
        NSMutableArray* items = [NSMutableArray arrayWithCapacity:(otherItems.count + (cancelItem ? 1 : 0))];
        if (cancelItem) {
            [items addObject:cancelItem];
        }
        
        if (otherItems) {
            [items addObjectsFromArray:otherItems];
        }
        
        self.items = items;
        
        [otherItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            TWGAlertItem* item = obj;
            [self addButtonWithTitle:item.title];
        }];
    }
    
    return self;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    TWGAlertItem* item = [self.items objectAtIndex:buttonIndex];
    if (item.block) {
        item.block();
    }
}

@end
