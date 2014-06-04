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
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}";
    return [[NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex] evaluateWithObject:emailAddress];
}

+ (BOOL)validateUsername:(NSString *)username {
    BOOL passedRegex = NO;
    BOOL passedLength = ([username length] <= 15);
    NSString *usernameRegex = @"[A-Z0-9a-z_]+";
    passedRegex = [[NSPredicate predicateWithFormat:@"SELF MATCHES %@", usernameRegex] evaluateWithObject:username];
    return (passedRegex && passedLength);
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

@end
