//
//  MRSLStateView.m
//  Morsel
//
//  Created by Marty Trzpit on 7/9/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLStateView.h"
#import "MRSLRobotoLightLabel.h"

static CGFloat kContainerWidth = 280.0f;
static CGFloat kContainerHeight = 48.0f;
static CGFloat kPadding = 10.0f;

@interface MRSLStateView ()

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) MRSLRobotoLightLabel *titleLabel;
@property (nonatomic, strong) UIView *accessoryView;

@end

@implementation MRSLStateView

#pragma mark - Class Methods

+ (instancetype)stateView {
    return [self stateViewWithWidth:kContainerWidth];
}

+ (instancetype)stateViewWithWidth:(CGFloat)width {
    return [[self alloc] initWithFrame:CGRectMake(0.0f, 0.0f, width, kContainerHeight)];
}


#pragma mark - Instance Methods

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.containerView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, CGRectGetWidth(frame), CGRectGetHeight(frame))];

        self.accessoryView = [[UIView alloc] initWithFrame:CGRectMake(kPadding, kPadding, CGRectGetHeight(_containerView.frame) - (kPadding * 2.0f), CGRectGetHeight(_containerView.frame) - (kPadding * 2.0f))];
        self.titleLabel = [[MRSLRobotoLightLabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_accessoryView.frame) + kPadding, kPadding, CGRectGetWidth(_containerView.frame) - (CGRectGetMaxX(_accessoryView.frame) + (kPadding * 2.0f)), CGRectGetHeight(_containerView.frame) - (kPadding * 2.0f))];
        [_containerView addSubview:_titleLabel];
        [_containerView addSubview:_accessoryView];

        [self addSubview:_containerView];

        [_containerView setCenter:CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame))];
    }
    return self;
}

- (void)setTitle:(NSString *)title {
    [self.titleLabel setText:title];
    CGSize fittedTextSize = [title sizeWithFont:_titleLabel.font
                 constrainedToSize:CGSizeMake(CGFLOAT_MAX, [_titleLabel getHeight])
                     lineBreakMode:NSLineBreakByWordWrapping];

    [_titleLabel setWidth:ceilf(fittedTextSize.width)];
    [self fitContainerToTitleWidth];
}

- (void)setAccessorySubview:(UIView *)accessorySubview {
    [[self.accessoryView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.accessoryView addSubview:accessorySubview];
    [accessorySubview setCenter:CGPointMake(CGRectGetWidth(_accessoryView.frame) * 0.5f, CGRectGetHeight(_accessoryView.frame) * 0.5f)];
}

- (CGPoint)defaultOffset {
    //  MT: Offsetting X if the accessoryView doesn't have a subview and
    //  Y up by the container's height to not make it look perfectly centered
    return [self hasAccessorySubview] ? CGPointMake(0.0f, -CGRectGetHeight(_containerView.frame)) : CGPointMake(-CGRectGetWidth(_accessoryView.frame), -CGRectGetHeight(_containerView.frame));
}


#pragma mark - Private Methods

- (void)fitContainerToTitleWidth {
    [_containerView setWidth:kPadding + [_accessoryView getWidth] + kPadding + [_titleLabel getWidth] + kPadding];
    [_containerView setCenter:CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))];
}

- (BOOL)hasAccessorySubview {
    return [[_accessoryView subviews] count] > 0;
}

@end
