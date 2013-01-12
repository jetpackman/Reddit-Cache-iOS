//
//  NSObject+TWG.m
//  The Working Group
//
//  Created by Jeremy Bower on 11-11-02.
//  Copyright (c) 2011 The Working Group. All rights reserved.
//

#import "NSObject+TWG.h"

@implementation NSObject (TWG)

- (id)nilForNull
{
    if ([self isKindOfClass:[NSNull class]]) {
        return nil;
    }
    
    return self;
}

- (void)performAfterDelay:(NSTimeInterval)delay onQueue:(NSOperationQueue*)queue block:(void(^)(void))block 
{
    [queue performSelector:@selector(addOperation:)
                withObject:[NSBlockOperation blockOperationWithBlock:block]
                afterDelay:delay];
}

@end
