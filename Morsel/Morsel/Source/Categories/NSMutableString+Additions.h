//
//  NSMutableString+Additions.h
//  Morsel
//
//  Created by Marty Trzpit on 6/3/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableString (Additions)

- (void)appendCommaSeparatedString:(NSString *)aString;
- (NSMutableString *)stringCleanedForPhonePrompt;

@end
