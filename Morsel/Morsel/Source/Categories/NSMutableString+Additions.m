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
        [self appendFormat:@", %@", aString];
    } else {
        [self appendString: aString];
    }
}

@end
