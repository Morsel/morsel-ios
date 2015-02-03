//
//  MRSLColoredBackgroundLightButton.h
//  Morsel
//
//  Created by Javier Otero on 1/24/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLLightButton.h"

@interface MRSLColoredBackgroundLightButton : MRSLLightButton

@property (nonatomic) BOOL allowsToggle;

@property (copy, nonatomic) UIColor *originalBackgroundColor;
@property (strong, nonatomic) UIColor *highlightedBackgroundColor;

- (void)setupColors;

@end
