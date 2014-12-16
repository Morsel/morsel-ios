//
//  MorselStandardLabel.h
//  Morsel
//
//  Created by Javier Otero on 1/23/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MRSLPrimaryLabel : UILabel

@property (nonatomic, getter=isOblique) BOOL oblique;

- (id)initWithFrame:(CGRect)frame andFontSize:(CGFloat)fontSize;
- (void)setUp;
- (UIFont *)obliqueFont;

@end
