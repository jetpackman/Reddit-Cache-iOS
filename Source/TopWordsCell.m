//
//  TopWordsCell.m
//  onething
//
//  Created by Anthony Wong on 12-05-09.
//  Copyright (c) 2012 1THING. All rights reserved.
//

#import "TopWordsCell.h"

@implementation TopWordsCell
@synthesize wordLabel = _wordLabel;
@synthesize countLabel = _countLabel;
@synthesize chevronImageView = _chevronImageView;


- (TopWordsCell*) configureCellForTopWord:(NSDictionary*) topWord
{
    // Set content on labels and resize to fit
    
    NSString* word = [topWord objectForKey:@"word"];
    NSString* count = [NSString stringWithFormat:@"(%@)",[topWord objectForKey:@"count"]];
                       
    self.wordLabel.text = word;
    self.countLabel.text = count;
    

    self.wordLabel.frame = CGRectMake(self.wordLabel.frame.origin.x, self.wordLabel.frame.origin.y, 320, self.wordLabel.frame.size.height);
    [self.wordLabel sizeToFit];
    self.countLabel.frame = CGRectMake(self.wordLabel.frame.size.width + self.wordLabel.frame.origin.x + 5, self.countLabel.frame.origin.y, self.countLabel.frame.size.width, self.countLabel.frame.size.height);
    
    return self;
}
@end
