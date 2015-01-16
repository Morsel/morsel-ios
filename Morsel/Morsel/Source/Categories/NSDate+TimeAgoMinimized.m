//
//  NSDate+TimeAgoMinimized.m
//  Morsel
//
//  Created by Javier Otero on 6/5/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "NSDate+TimeAgoMinimized.h"

#import <DateTools/NSDate+DateTools.h>

#ifndef NSDateTimeAgoLocalizedStrings
#define NSDateTimeAgoLocalizedStrings(key) \
NSLocalizedStringFromTableInBundle(key, @"NSDateTimeAgo", [NSBundle bundleWithPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"NSDateTimeAgo.bundle"]], nil)
#endif

@implementation NSDate (TimeAgoMinimized)

- (NSString *)timeAgoMinimized
{
    NSDate *now = [NSDate date];
    double deltaSeconds = fabs([self timeIntervalSinceDate:now]);
    double deltaMinutes = deltaSeconds / 60.0f;

    int minutes;

    if(deltaSeconds < 5)
    {
        return NSDateTimeAgoLocalizedStrings(@"now");
    }
    else if(deltaSeconds < 60)
    {
        return [self stringFromFormat:@"%%d%@s" withValue:deltaSeconds];
    }
    else if(deltaSeconds < 120)
    {
        return NSDateTimeAgoLocalizedStrings(@"1m");
    }
    else if (deltaMinutes < 60)
    {
        return [self stringFromFormat:@"%%d%@m" withValue:deltaMinutes];
    }
    else if (deltaMinutes < 120)
    {
        return NSDateTimeAgoLocalizedStrings(@"1h");
    }
    else if (deltaMinutes < (24 * 60))
    {
        minutes = (int)floor(deltaMinutes/60);
        return [self stringFromFormat:@"%%d%@h" withValue:minutes];
    }
    else if (deltaMinutes < (24 * 60 * 2))
    {
        return NSDateTimeAgoLocalizedStrings(@"1d");
    }
    else if (deltaMinutes < (24 * 60 * 7))
    {
        minutes = (int)floor(deltaMinutes/(60 * 24));
        return [self stringFromFormat:@"%%d%@d" withValue:minutes];
    }
    else if (deltaMinutes < (24 * 60 * 14))
    {
        return NSDateTimeAgoLocalizedStrings(@"1w");
    }
    else if (deltaMinutes < (24 * 60 * 31))
    {
        minutes = (int)floor(deltaMinutes/(60 * 24 * 7));
        return [self stringFromFormat:@"%%d%@w" withValue:minutes];
    }
    else if (deltaMinutes < (24 * 60 * 61))
    {
        return NSDateTimeAgoLocalizedStrings(@"1mo");
    }
    else if (deltaMinutes < (24 * 60 * 365.25))
    {
        minutes = (int)floor(deltaMinutes/(60 * 24 * 30));
        return [self stringFromFormat:@"%%d%@mo" withValue:minutes];
    }
    else if (deltaMinutes < (24 * 60 * 731))
    {
        return NSDateTimeAgoLocalizedStrings(@"1y");
    }

    minutes = (int)floor(deltaMinutes/(60 * 24 * 365));
    return [self stringFromFormat:@"%%d%@y" withValue:minutes];
}

- (NSString *) stringFromFormat:(NSString *)format withValue:(NSInteger)value
{
    NSString * localeFormat = [NSString stringWithFormat:format, [self getLocaleFormatUnderscoresWithValue:value]];
    return [NSString stringWithFormat:NSDateTimeAgoLocalizedStrings(localeFormat), value];
}

-(NSString *)getLocaleFormatUnderscoresWithValue:(double)value
{
    NSString *localeCode = [[NSLocale preferredLanguages] objectAtIndex:0];

    // Russian (ru)
    if([localeCode isEqual:@"ru"]) {
        NSString *valueStr = [NSString stringWithFormat:@"%.f", value];
        int l = (int)valueStr.length;
        int XY = [[valueStr substringWithRange:NSMakeRange(l - 2, l)] intValue];
        int Y = (int)floor(value) % 10;

        if(Y == 0 || Y > 4 || XY == 11) return @"";
        if(Y != 1 && Y < 5)             return @"_";
        if(Y == 1)                      return @"__";
    }

    // Add more languages here, which are have specific translation rules...

    return @"";
}

@end
