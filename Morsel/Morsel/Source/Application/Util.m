//
//  Util.m
//  Morsel
//
//  Created by Javier Otero on 1/14/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "Util.h"

@implementation Util

+ (BOOL)validateEmail:(NSString *)emailAddress {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}";
    NSPredicate *emailValidation = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];

    return [emailValidation evaluateWithObject:emailAddress];
}

+ (BOOL)validateUsername:(NSString *)username {
    BOOL passedRegex = NO;
    BOOL passedLength = ([username length] <= 15);

    NSString *usernameRegex = @"[A-Z0-9a-z_]+";
    NSPredicate *usernameValidation = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", usernameRegex];

    passedRegex = [usernameValidation evaluateWithObject:username];

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
