//
//  NSString+Additions.m
//  Morsel
//
//  Created by Marty Trzpit on 6/5/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "NSString+Additions.h"

@implementation NSString (Additions)

- (BOOL)isEmpty {
    return [self length] == 0;
}

- (NSString *)stringWithEncoding:(NSStringEncoding)encoding {
    return (NSString *) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self,
                                                                NULL, (CFStringRef)@";/?:@&=$+{}<>,",
                                                                CFStringConvertNSStringEncodingToEncoding(encoding)));
}

- (NSString *)stringWithNSUTF8StringEncoding {
    return [self stringWithEncoding:NSUTF8StringEncoding];
}

- (NSString *)stringWithWhitespaceTrimmed {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

@end
