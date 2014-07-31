//
//  MRSLSectionCollectionReusableView.m
//  Morsel
//
//  Created by Marty Trzpit on 7/31/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLSectionCollectionReusableView.h"

@interface MRSLSectionCollectionReusableView ()

@property (nonatomic, strong) MRSLSectionView *sectionView;

@end

@implementation MRSLSectionCollectionReusableView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _sectionView = [MRSLSectionView sectionViewWithTitle:nil];
        [self addSubview:_sectionView];
    }
    return self;
}

- (void)setTitle:(NSString *)title {
    [self.sectionView setTitle:title];
}

@end
