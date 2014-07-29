//
//  MRSLColoredBackgroundToggleButton.h
//  Morsel
//
//  Created by Javier Otero on 6/6/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLColoredBackgroundLightButton.h"

@interface MRSLSegmentButton : MRSLLightButton

@property (nonatomic) BOOL allowsToggle;

@property (copy, nonatomic) UIColor *originalBackgroundColor;
@property (strong, nonatomic) UIColor *highlightedBackgroundColor;

@end
