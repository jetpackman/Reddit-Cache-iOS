//
//  NSObject+TWG.h
//  The Working Group
//
//  Created by Jeremy Bower on 11-11-02.
//  Copyright (c) 2011 The Working Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (TWG)

- (id)nilForNull;

- (void)performAfterDelay:(NSTimeInterval)delay onQueue:(NSOperationQueue*)queue block:(void(^)(void))block;

@end
