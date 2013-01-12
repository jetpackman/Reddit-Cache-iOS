//
//  NSNotification+TWG.m
//  Nitro
//
//  Created by Jeremy Bower on 12-02-02.
//  Copyright (c) 2012 none. All rights reserved.
//

#import "NSNotification+TWG.h"

@implementation NSNotification (TWG)

- (CGFloat)keyboardHeight 
{
    CGRect startFrame;
    NSValue *startFrameValue = [self.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    if (startFrameValue) {
        [startFrameValue getValue:&startFrame];
        return startFrame.size.height;
    } 
    else {
        return 0;
    }
}

- (NSTimeInterval)keyboardAnimationDuration
{
    NSValue* value = [self.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    if (value) {
        NSTimeInterval duration = 0;
        [value getValue:&duration];
        return duration;
    }
    else {
        return 0;
    }
}

@end
