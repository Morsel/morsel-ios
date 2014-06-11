//
//  Util.h
//  Morsel
//
//  Created by Javier Otero on 1/14/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MRSLUtil : NSObject

+ (BOOL)validateEmail:(NSString *)emailAddress;
+ (NSArray *)validationErrorsForEmail:(NSString *)emailAddress;

+ (BOOL)validateUsername:(NSString *)username;
+ (NSArray *)validationErrorsForUsername:(NSString *)username;

+ (BOOL)imageIsLandscape:(UIImage *)image;
+ (CGFloat)cameraDimensionScaleFromImage:(UIImage *)image;

+ (Class)classForDataSourceType:(MRSLDataSourceType)dataSourceTabType;
+ (NSString *)stringForDataSortType:(MRSLDataSortType)dataSortType;
+ (NSString *)stringForDataSourceType:(MRSLDataSourceType)dataSourceTabType;
+ (NSString *)appVersionBuildString;
+ (NSString *)appMajorMinorPatchString;
+ (NSString *)supportDiagnostics;
+ (NSString *)supportDiagnosticsURLParams;
+ (NSString *)deviceModel;
+ (NSString *)deviceVersion;

@end
