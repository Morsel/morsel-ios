//
//  Util.h
//  Morsel
//
//  Created by Javier Otero on 1/14/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Util : NSObject

+ (BOOL)validateEmail:(NSString *)candidate;
+ (BOOL)validateUsername:(NSString *)username;

+ (BOOL)imageIsLandscape:(UIImage *)image;
+ (CGFloat)cameraDimensionScaleFromImage:(UIImage *)image;

@end
