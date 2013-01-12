//
//  TWGActionSheet.m
//  twg-helpers-ios
//
//  Created by Jeremy Bower on 12-04-07.
//  Copyright (c) 2012 The Working Group. All rights reserved.
//

#import "TWGActionSheet.h"

@implementation TWGActionItem

@synthesize title = _title;
@synthesize block = _block;

+ (TWGActionItem*)actionItemWithTitle:(NSString*)title
{
    return [TWGActionItem actionItemWithTitle:title block:nil];
}

+ (TWGActionItem*)actionItemWithTitle:(NSString*)title block:(TWGActionBlock)block
{
    return [[TWGActionItem alloc] initWithTitle:title block:block];
}

- (id)initWithTitle:(NSString*)title block:(TWGActionBlock)block
{
    self = [super init];
    if (self) {
        self.title = title;
        self.block = block;
    }
    
    return self;
}

@end

@implementation TWGActionSheet

@synthesize items = _items;

+ (TWGActionSheet*)actionSheetWithTitle:(NSString *)title 
                             cancelItem:(TWGActionItem*)cancelItem
                        destructiveItem:(TWGActionItem*)destructiveItem
                             otherItems:(NSArray*)otherItems
{
    return [[TWGActionSheet alloc] initWithTitle:title 
                                      cancelItem:cancelItem
                                 destructiveItem:destructiveItem
                                      otherItems:otherItems];
}

- (id)initWithTitle:(NSString *)title 
         cancelItem:(TWGActionItem*)cancelItem
    destructiveItem:(TWGActionItem*)destructiveItem
         otherItems:(NSArray*)otherItems
{
    self = [super initWithTitle:title delegate:self 
              cancelButtonTitle:nil
         destructiveButtonTitle:nil
              otherButtonTitles:nil];
    
    if (self) {
        NSMutableArray* items = [NSMutableArray arrayWithCapacity:(otherItems.count + (destructiveItem ? 1 : 0) + (cancelItem ? 1 : 0))];
        
        if (destructiveItem) {
            [items addObject:destructiveItem];
        }
        
        if (otherItems) {
            [items addObjectsFromArray:otherItems];
        }
        
        if (cancelItem) {
            [items addObject:cancelItem];
        }
        
        self.items = items;
        
        [self.items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            TWGActionItem* item = obj;
            [self addButtonWithTitle:item.title];
        }];
        
        if (destructiveItem) {
            self.destructiveButtonIndex = 0;
        }
        
        if (cancelItem) {
            self.cancelButtonIndex = self.items.count - 1;
        }
    }
    
    return self;
}

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (0 <= buttonIndex && buttonIndex < self.items.count) {
        TWGActionItem* item = [self.items objectAtIndex:buttonIndex];
        if (item.block) {
            item.block();
        }
    }
}

@end
