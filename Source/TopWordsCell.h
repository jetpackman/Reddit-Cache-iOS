//
//  TopWordsCell.h
//  onething
//
//  Created by Anthony Wong on 12-05-09.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TopWordsCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *wordLabel;
@property (strong, nonatomic) IBOutlet UILabel *countLabel;
@property (strong, nonatomic) IBOutlet UIImageView *chevronImageView;

- (TopWordsCell*) configureCellForTopWord:(NSDictionary*) topWord;

@end
