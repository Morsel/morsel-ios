//
//  Util.m
//  Morsel
//
//  Created by Javier Otero on 1/14/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLUtil.h"

#import "MRSLActivity.h"
#import "MRSLMorsel.h"
#import "MRSLPlace.h"
#import "MRSLItem.h"
#import "MRSLTag.h"
#import "MRSLUser.h"

@implementation MRSLUtil

+ (BOOL)validateEmail:(NSString *)emailAddress {
    return [self validationErrorsForEmail:emailAddress] == nil;
}

+ (NSArray *)validationErrorsForEmail:(NSString *)emailAddress {
    //  Return right away if empty
    if ([emailAddress length] == 0) return @[@"is required"];

    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}";
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

    if ([[NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"[a-zA-Z][A-Za-z0-9_]+$"] evaluateWithObject:username]) [errors addObject:@"must start with a letter and can only contain alphanumeric characters and underscores"];

    return ([errors count] > 0) ? errors : nil;
}


+ (BOOL)imageIsLandscape:(UIImage *)image {
    // Temporarily using width to height comparison due to jpegStillImageNSDataRepresentation: not capturing image orientation

    return (image.size.width > image.size.height);
    /*
     switch (image.imageOrientation)
     {
     case UIImageOrientationUp:
     case UIImageOrientationUpMirrored:
     case UIImageOrientationDown:
     case UIImageOrientationDownMirrored:
     // Portrait
     return NO;
     break;
     default:
     // Landscape
     return YES;
     break;
     }
     */
}

+ (CGFloat)cameraDimensionScaleFromImage:(UIImage *)image {
    BOOL isLandscape = [self imageIsLandscape:image];

    //DDLogDebug(@"Image is Landscape? %@", (isLandscape) ? @"YES" : @"NO");

    CGFloat cameraResolutionScale = ((isLandscape) ? image.size.height : image.size.width) / minimumCameraMaxDimension;
    CGFloat dimensionScale = ((isLandscape) ? standardCameraDimensionLandscapeMultiplier : standardCameraDimensionPortraitMultiplier)  *cameraResolutionScale;

    //DDLogDebug(@"Camera Resolution Scale: %f", cameraResolutionScale);
    //DDLogDebug(@"Camera Dimension Scale Multiplier: %f", dimensionScale);

    return dimensionScale;
}

+ (Class)classForDataSourceType:(MRSLDataSourceType)dataSourceTabType {
    switch (dataSourceTabType) {
        case MRSLDataSourceTypeMorsel:
            return [MRSLMorsel class];
            break;
        case MRSLDataSourceTypeActivityItem:
            return [MRSLItem class];
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
        case MRSLDataSortTypeNone:
        default:
            return nil;
            break;
    }
}

+ (NSString *)stringForDataSourceType:(MRSLDataSourceType)dataSourceTabType {
    switch (dataSourceTabType) {
        case MRSLDataSourceTypeMorsel:
            return @"morsel";
            break;
        case MRSLDataSourceTypeActivityItem:
            return @"item";
            break;
        case MRSLDataSourceTypePlace:
            return @"place";
            break;
        case MRSLDataSourceTypeTag:
            return @"tag";
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
        [currentDevice model],
        [currentDevice systemVersion]];

    // Device Info
}

+ (NSString *)supportDiagnosticsURLParams {
    UIDevice *currentDevice = [UIDevice currentDevice];

    return [NSString stringWithFormat:@"user_id=%@&app_version=%@&device_model=%@&device_system_version=%@", [[MRSLUser currentUser] userID], [[MRSLUtil appMajorMinorPatchString] stringWithNSUTF8StringEncoding], [[currentDevice model] stringWithNSUTF8StringEncoding], [[currentDevice systemVersion] stringWithNSUTF8StringEncoding]];
}

@end
