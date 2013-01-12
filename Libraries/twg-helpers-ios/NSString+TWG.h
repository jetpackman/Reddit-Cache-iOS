//
//  NSString+TWG.h
//  The Working Group
//
//  Created by Jeremy Bower on 11-11-09.
//  Copyright (c) 2011 The Working Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (TWG)

+ (NSString*)stringWithData:(NSData*)data encoding:(NSStringEncoding)encoding;

+ (NSString*)encodeBase64WithString:(NSString *)strData;
+ (NSString*)encodeBase64WithData:(NSData *)objData;

- (NSString*)trimWhitespace;
- (NSString*)nilForEmptyString;

- (NSString*)formatPhoneNumber;

@end
