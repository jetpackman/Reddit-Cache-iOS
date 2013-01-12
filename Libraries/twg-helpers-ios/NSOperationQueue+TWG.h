//
//  NSOperationQueue+TWG.h
//  The Working Group
//
//  Created by Jeremy Bower on 11-11-13.
//  Copyright (c) 2011 The Working Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSOperationQueue (TWG)

+ (NSOperationQueue*)backgroundQueue;

- (void)waitForOperationWithBlock:(void (^)(void))block;

@end
