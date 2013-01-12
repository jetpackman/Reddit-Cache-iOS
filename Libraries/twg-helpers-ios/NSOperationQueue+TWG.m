//
//  NSOperationQueue+TWG.m
//  The Working Group
//
//  Created by Jeremy Bower on 11-11-13.
//  Copyright (c) 2011 The Working Group. All rights reserved.
//

#import "NSOperationQueue+TWG.h"

@implementation NSOperationQueue (TWG)

+ (NSOperationQueue*)backgroundQueue 
{
    static NSOperationQueue* backgroundQueue = nil;
    if (!backgroundQueue) {
        backgroundQueue = [[NSOperationQueue alloc] init];
    }
    
    return backgroundQueue;
}

- (void)waitForOperationWithBlock:(void (^)(void))block
{
    if (self == [NSOperationQueue currentQueue]) {
        block();
    }
    else {
        [self addOperations:[NSArray arrayWithObject:[NSBlockOperation blockOperationWithBlock:block]]
          waitUntilFinished:YES];
    }
}

@end
