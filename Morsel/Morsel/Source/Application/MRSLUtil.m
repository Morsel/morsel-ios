//
//  Util.m
//  Morsel
//
//  Created by Javier Otero on 1/14/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLUtil.h"

#import "MRSLActivity.h"
#import "MRSLCollection.h"
#import "MRSLMorsel.h"
#import "MRSLPlace.h"
#import "MRSLItem.h"
#import "MRSLTag.h"
#import "MRSLUser.h"

#import <sys/sysctl.h>

@implementation MRSLUtil

+ (BOOL)validateEmail:(NSString *)emailAddress {
    return [self validationErrorsForEmail:emailAddress] == nil;
}

+ (NSArray *)validationErrorsForEmail:(NSString *)emailAddress {
    //  Return right away if empty
    if ([emailAddress length] == 0) return @[@"is required"];

    //  MT: Since new TLDs can be longer than 6 characters, removed max 6 char limit. Just check TLDs is min 2 char.
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}";
    if (![[NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex] evaluateWithObject:emailAddress]) return @[@"is invalid"];
    
    return nil;
}

+ (BOOL)validateUsername:(NSString *)username {
    return [self validationErrorsForUsername:username] == nil;
}

+ (NSArray *)validationErrorsForUsername:(NSString *)username {
    //  Return right away if empty
    if ([username length] == 0) return @[@"is required"];

    NSMutableArray *errors = [NSMutableArray array];

    if ([username length] > 15) [errors addObject:@"must be less than 16 characters"];
    
    NSRange whiteSpaceRange = [username rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];
    if (whiteSpaceRange.location != NSNotFound) [errors addObject:@"cannot contain spaces"];

    if (![[NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"[a-zA-Z]([A-Za-z0-9_]*)$"] evaluateWithObject:username]) [errors addObject:@"must start with a letter and can only contain alphanumeric characters and underscores"];

    return ([errors count] > 0) ? errors : nil;
}

+ (BOOL)dropboxAvailable {
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"dbapi-3://1/chooser"]];
}

+ (Class)classForDataSourceType:(MRSLDataSourceType)dataSourceTabType {
    switch (dataSourceTabType) {
        case MRSLDataSourceTypeMorsel:
        case MRSLDataSourceTypeLikedMorsel:
            return [MRSLMorsel class];
            break;
        case MRSLDataSourceTypePlace:
            return [MRSLPlace class];
            break;
        case MRSLDataSourceTypeTag:
            return [MRSLTag class];
            break;
        case MRSLDataSourceTypeUser:
            return [MRSLUser class];
            break;
        case MRSLDataSourceTypeCollection:
            return [MRSLCollection class];
            break;
        default:
            return [NSNull class];
            break;
    }
}

+ (NSString *)stringForDataSortType:(MRSLDataSortType)dataSortType {
    switch (dataSortType) {
        case MRSLDataSortTypeCreationDate:
            return @"creationDate";
            break;
        case MRSLDataSortTypeName:
            return @"name";
            break;
        case MRSLDataSortTypeLastName:
            return @"last_name";
            break;
        case MRSLDataSortTypeSortOrder:
            return @"sort_order";
            break;
        case MRSLDataSortTypeLikedDate:
            return @"likedDate";
            break;
        case MRSLDataSortTypeTagKeywordType:
            return @"keyword.type,keyword.name";
            break;
        case MRSLDataSortTypePublishedDate:
            return @"publishedDate";
            break;
        case MRSLDataSortTypeNone:
        default:
            return nil;
            break;
    }
}

+ (NSString *)stringForDataSourceType:(MRSLDataSourceType)dataSourceTabType {
    switch (dataSourceTabType) {
        case MRSLDataSourceTypeMorsel:
        case MRSLDataSourceTypeLikedMorsel:
            return @"morsel";
            break;
        case MRSLDataSourceTypePlace:
            return @"place";
            break;
        case MRSLDataSourceTypeTag:
            return @"tag";
            break;
        case MRSLDataSourceTypeCollection:
            return @"collection";
            break;
        case MRSLDataSourceTypeUser:
            return @"user";
            break;
        default:
            return @"unknown";
            break;
    }
}

+ (NSString *)appVersionBuildString {
    NSString * versionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString * buildString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    return [NSString stringWithFormat:@"Version: %@ (%@)", versionString, buildString];
}

+ (NSString *)appMajorMinorPatchString {
    NSString * versionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString * buildString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    return [NSString stringWithFormat:@"%@.%@", versionString, buildString];
}

+ (NSString *)supportDiagnostics {
    UIDevice *currentDevice = [UIDevice currentDevice];

    return [NSString stringWithFormat:@"<i>Support Information</i>\
        <ul> \
            <li> \
                User ID: %1$@\
            </li> \
            <li> \
                App Version: %2$@ \
            </li> \
            <li> \
                Device: %3$@ - %4$@ \
            </li> \
        </ul> \
    ",  [[MRSLUser currentUser] userID],
        [MRSLUtil appMajorMinorPatchString],
        [MRSLUtil deviceModel],
        [currentDevice systemVersion]];

    // Device Info
}

+ (NSString *)supportDiagnosticsURLParams {
    UIDevice *currentDevice = [UIDevice currentDevice];

    return [NSString stringWithFormat:@"user_id=%@&app_version=%@&device_model=%@&device_system_version=%@", [[MRSLUser currentUser] userID], [[MRSLUtil appMajorMinorPatchString] stringWithNSUTF8StringEncoding], [[currentDevice model] stringWithNSUTF8StringEncoding], [[currentDevice systemVersion] stringWithNSUTF8StringEncoding]];
}

+ (NSString *)deviceModel {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);

    char *answer = malloc(size);
    sysctlbyname("hw.machine", answer, &size, NULL, 0);

    NSString *results = [NSString stringWithCString:answer encoding:NSUTF8StringEncoding];

    free(answer);
    return results;
}

+ (NSString *)deviceVersion {
    return [[UIDevice currentDevice] systemVersion];
}

@end
