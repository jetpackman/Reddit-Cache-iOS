//
//  TWGActionSheet.h
//  twg-helpers-ios
//
//  Created by Jeremy Bower on 12-04-07.
//  Copyright (c) 2012 The Working Group. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^TWGActionBlock)();

@interface TWGActionItem : NSObject 

@property (nonatomic, strong) NSString* title;
@property (nonatomic, copy) TWGActionBlock block;

+ (TWGActionItem*)actionItemWithTitle:(NSString*)title;

+ (TWGActionItem*)actionItemWithTitle:(NSString*)title block:(TWGActionBlock)block;

- (id)initWithTitle:(NSString*)title block:(TWGActionBlock)block;

@end

@interface TWGActionSheet : UIActionSheet <UIActionSheetDelegate>

@property (nonatomic, strong) NSArray* items;

+ (TWGActionSheet*)actionSheetWithTitle:(NSString *)title 
                             cancelItem:(TWGActionItem*)cancelItem
                        destructiveItem:(TWGActionItem*)destructiveItem
                             otherItems:(NSArray*)otherItems;

- (id)initWithTitle:(NSString *)title 
         cancelItem:(TWGActionItem*)cancelItem
    destructiveItem:(TWGActionItem*)destructiveItem
         otherItems:(NSArray*)otherItems;

@end
