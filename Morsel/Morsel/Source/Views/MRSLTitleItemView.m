//
//  MRSLTitleItemView.m
//  Morsel
//
//  Created by Javier Otero on 8/18/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLTitleItemView.h"

#import "MRSLRobotoSlabBoldLabel.h"

@interface MRSLTitleItemView ()

@property (weak, nonatomic) UIImageView *morselTitleImageView;
@property (weak, nonatomic) UILabel *morselTitleLabel;

@end

@implementation MRSLTitleItemView

#pragma mark - Instance Methods

- (id)init {
    self = [super init];
    if (self) {
        [self setUp];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setUp];
    }
    return self;
}

#pragma mark - Private Methods

- (void)setUp {
    self.clipsToBounds = NO;
    [self.subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
        [subview removeFromSuperview];
    }];
    UIImageView *titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"graphic-identity-nav"]];
    [titleView setY:2.f];
    [titleView setX:((self.frame.size.width / 2) - (titleView.frame.size.width / 2))];
    [self addSubview:titleView];

    [self setWidth:titleView.frame.size.width];
    [self setHeight:titleView.frame.size.height];

    MRSLRobotoSlabBoldLabel *titleLabel = [[MRSLRobotoSlabBoldLabel alloc] initWithFrame:self.frame
                                                                             andFontSize:17.f];
    [titleLabel setWidth:180.f];
    [titleLabel setX:((self.frame.size.width / 2) - (titleLabel.frame.size.width / 2))];
    titleLabel.numberOfLines = 2;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.alpha = 0.f;
    [self addSubview:titleLabel];

    self.morselTitleImageView = titleView;
    self.morselTitleLabel = titleLabel;
}

- (void)setTitle:(NSString *)title {
    _title = title;

    BOOL titleExists = (title != nil);

    self.morselTitleLabel.text = title;

    [UIView animateWithDuration:.5f
                     animations:^{
                         self.morselTitleImageView.alpha = !titleExists;
                         self.morselTitleLabel.alpha = titleExists;
                     }];
}

@end
