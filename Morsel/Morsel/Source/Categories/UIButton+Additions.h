//
//  UIButton+Additions.h
//  Morsel
//
//  Created by Javier Otero on 9/3/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#define kUIButtonBlockTouchUpInside @"TouchInside"

#import <UIKit/UIKit.h>

@interface UIButton (Additions)

@property (nonatomic, strong) NSMutableDictionary *actions;

- (void) setAction:(NSString*)action
         withBlock:(void(^)())block;

@end
