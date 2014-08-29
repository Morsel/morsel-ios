//
//  MRSLTemplateSelectionCollectionViewCell.m
//  Morsel
//
//  Created by Javier Otero on 8/19/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLTemplateSelectionCollectionViewCell.h"

#import "MRSLTemplate.h"

@interface MRSLTemplateSelectionCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation MRSLTemplateSelectionCollectionViewCell

#pragma mark - Instance Methods

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setRoundedCornerRadius:4.f];
}

- (void)setMorselTemplate:(MRSLTemplate *)morselTemplate {
    _morselTemplate = morselTemplate;

    self.iconImageView.image = [UIImage imageNamed:morselTemplate.icon];
    self.titleLabel.text = morselTemplate.title;
}

- (UIColor *)defaultBackgroundColor {
    return [UIColor morselPrimary];
}

- (UIColor *)defaultHighlightedBackgroundColor {
    return [self defaultSelectedBackgroundColor];
}

- (UIColor *)defaultSelectedBackgroundColor {
    return [[UIColor morselPrimary] colorWithBrightness:.8f];
}

@end
