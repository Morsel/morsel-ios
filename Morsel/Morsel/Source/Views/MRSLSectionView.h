//
//  MRSLSectionView.h
//  Morsel
//
//  Created by Marty Trzpit on 7/28/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

static const CGFloat MRSLSectionViewDefaultHeight = 24.0f;

@interface MRSLSectionView : UIView

+ (instancetype)sectionViewWithTitle:(NSString *)title;

- (void)setTitle:(NSString *)title;

@end
