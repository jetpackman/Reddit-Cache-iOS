//
//  TWGGroupedTableViewCellBackground.h
//  The Working Group
//
//  Created by Jeremy Bower on 11-11-11.
//  Copyright (c) 2011 The Working Group. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum  {
    TWGGroupedTableViewCellPositionTop, 
    TWGGroupedTableViewCellPositionMiddle, 
    TWGGroupedTableViewCellPositionBottom,
    TWGGroupedTableViewCellPositionSingle
} TWGGroupedTableViewCellPosition;

@interface TWGGroupedTableViewCellBackground : UIView 

@property (nonatomic, strong) UIColor* borderColor;
@property (nonatomic, strong) UIColor* fillColor;
@property (nonatomic, assign) TWGGroupedTableViewCellPosition position;

+ (TWGGroupedTableViewCellBackground*)backgroundWithBorderColor:(UIColor*)borderColor
                                                      fillColor:(UIColor*)fillColor
                                                       position:(TWGGroupedTableViewCellPosition)position;


@end
