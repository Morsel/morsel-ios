//
//  NSMutableString+Additions.m
//  Morsel
//
//  Created by Marty Trzpit on 6/3/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "NSMutableString+Additions.h"

@implementation NSMutableString (Additions)

- (void)appendCommaSeparatedString:(NSString *)aString {
    if (self.length > 0) {
        NSString *potentialNewlineString = nil;
        if (self.length >= 2) {
            NSRange potentialNewlineRange = NSMakeRange(self.length - 1, 1);
            potentialNewlineString = [self substringWithRange:potentialNewlineRange];
        }
        if (![potentialNewlineString isEqualToString:@"\n"]) {
            [self appendFormat:@", %@", aString];
        } else {
            [self appendString:aString];
        }
    } else {
        [self appendString:aString];
    }
}

- (NSMutableString *)stringCleanedForPhonePrompt {
    [self setString:[self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    [self setString:[self stringByReplacingOccurrencesOfString:@"(" withString:@""]];
    [self setString:[self stringByReplacingOccurrencesOfString:@")" withString:@""]];
    [self setString:[self stringByReplacingOccurrencesOfString:@"-" withString:@""]];
    [self setString:[self stringByReplacingOccurrencesOfString:@" " withString:@""]];
    return self;
}

@end
