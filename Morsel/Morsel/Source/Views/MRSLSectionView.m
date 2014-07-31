//
//  MRSLSectionView.m
//  Morsel
//
//  Created by Marty Trzpit on 7/28/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLSectionView.h"
#import "MRSLRobotoSlabBoldLabel.h"

@interface MRSLSectionView()

@property (nonatomic, strong) MRSLRobotoSlabBoldLabel *label;

@end

@implementation MRSLSectionView

#pragma mark - Class Methods

+ (instancetype)sectionViewWithTitle:(NSString *)title {
    MRSLSectionView *sectionView = [[MRSLSectionView alloc] initWithFrame:CGRectMake(0.f, 0.f, 320.f, 24.f)];

    if (title) [sectionView.label setText:[title uppercaseString]];

    return sectionView;
}


#pragma mark - Instance Methods

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _label = [[MRSLRobotoSlabBoldLabel alloc] initWithFrame:CGRectMake(16.f, 5.f, 240.f, 14.f)
                                                    andFontSize:12.f];

        _label.textColor = [[UIColor morselDark] colorWithBrightness:1.4f];
        _label.backgroundColor = [UIColor clearColor];

        [self setBackgroundColor:[UIColor morselDefaultSectionHeaderBackgroundColor]];
        [self addSubview:_label];
        [self addDefaultBorderForDirections:(MRSLBorderNorth|MRSLBorderSouth)];
    }
    return self;
}

- (void)setTitle:(NSString *)title {
    [self.label setText:title];
}

@end
