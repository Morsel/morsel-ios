//
//  MRSLStateView.m
//  Morsel
//
//  Created by Marty Trzpit on 7/9/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLStateView.h"
#import "MRSLPrimaryLightLabel.h"
#import "MRSLColoredBackgroundLightButton.h"

static CGFloat kContainerWidth = 320.0f;
static CGFloat kContainerHeight = 48.0f;
static CGFloat kPadding = MRSLDefaultPadding;
static CGFloat kButtonHeight = 40.0f;

@interface MRSLStateView ()

@property (strong, nonatomic) UIView *containerView;
@property (strong, nonatomic) MRSLPrimaryLightLabel *titleLabel;
@property (strong, nonatomic) UIView *accessoryView;
@property (strong, nonatomic) MRSLColoredBackgroundLightButton *button;

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
        self.titleLabel = [[MRSLPrimaryLightLabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_accessoryView.frame) + kPadding, kPadding, CGRectGetWidth(_containerView.frame) - (CGRectGetMaxX(_accessoryView.frame) + (kPadding * 2.0f)), CGRectGetHeight(_containerView.frame) - (kPadding * 2.0f))];
        [_titleLabel setBackgroundColor:[UIColor clearColor]];

        [_containerView addSubview:_titleLabel];
        [_containerView addSubview:_accessoryView];

        [self addSubview:_containerView];

        [_containerView setCenter:CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame) - kContainerHeight)];
    }
    return self;
}

- (MRSLColoredBackgroundLightButton *)button {
    if (!_button) {
        _button = [[MRSLColoredBackgroundLightButton alloc] initWithFrame:CGRectMake(kPadding, 0.0f, kContainerWidth - (kPadding * 2.0f), kButtonHeight)];
        [_button addTarget:self
                    action:@selector(buttonPressed:)
          forControlEvents:UIControlEventTouchUpInside];
        [_containerView addSubview:_button];
        [_containerView setHeight:kContainerHeight + kPadding + kButtonHeight];
        [_button setY:CGRectGetMaxY(_titleLabel.frame) + kPadding];

        [_button setBackgroundColor:[UIColor morselPrimary]];
        [_button.titleLabel setFont:[UIFont primaryLightFontOfSize:14.0f]];
    }

    return _button;
}

- (void)setTitle:(NSString *)title {
    [self.titleLabel setText:title];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;

    CGRect textRect = [title boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, CGFLOAT_MAX)
                                                          options:NSStringDrawingUsesLineFragmentOrigin
                                                       attributes:@{NSFontAttributeName: _titleLabel.font,
                                                                    NSParagraphStyleAttributeName: paragraphStyle}
                                                          context:nil];
    [_titleLabel setWidth:ceilf(textRect.size.width)];
    [_titleLabel setCenter:CGPointMake(CGRectGetWidth(_containerView.frame) * 0.5f, _titleLabel.center.y)];
}

- (void)setButtonTitle:(NSString *)title {
    if (title ) {
        [self.button setHidden:NO];
        [self.button setTitle:title
                     forState:UIControlStateNormal];
        [self.button setHeight:kButtonHeight];
        [self.button setCenter:CGPointMake(CGRectGetWidth(_containerView.frame) * 0.5f, self.button.center.y)];
    } else {
        [self.button setHidden:YES];
    }
}

- (void)setAccessorySubview:(UIView *)accessorySubview {
    [[self.accessoryView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.accessoryView addSubview:accessorySubview];
    [accessorySubview setCenter:CGPointMake(CGRectGetWidth(_accessoryView.frame) * 0.5f, CGRectGetHeight(_accessoryView.frame) * 0.5f)];
}

- (CGPoint)defaultOffset {
    return CGPointZero;
}


#pragma mark - Private Methods

- (void)buttonPressed:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(stateView:didSelectButton:)])
        [self.delegate stateView:self didSelectButton:sender];
}

- (BOOL)hasAccessorySubview {
    return [[_accessoryView subviews] count] > 0;
}

@end
