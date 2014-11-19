//
//  NSString+Additions.h
//  Morsel
//
//  Created by Marty Trzpit on 6/5/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Additions)

- (NSString *)stringWithEncoding:(NSStringEncoding)encoding;
- (NSString *)stringWithNSUTF8StringEncoding;
- (NSString *)stringWithWhitespaceTrimmed;

@end
