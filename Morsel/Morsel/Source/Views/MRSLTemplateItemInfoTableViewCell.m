//
//  MRSLTemplateInfoTableViewCell.m
//  Morsel
//
//  Created by Javier Otero on 8/20/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLTemplateItemInfoTableViewCell.h"

#import "MRSLTemplateItem.h"

@interface MRSLTemplateItemInfoTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *templateImageView;
@property (weak, nonatomic) IBOutlet UILabel *positionLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@end

@implementation MRSLTemplateItemInfoTableViewCell

- (void)setTemplateItem:(MRSLTemplateItem *)templateItem {
    _templateItem = templateItem;
    self.positionLabel.text =[NSString stringWithFormat:@"%i", templateItem.placeholder_sort_orderValue];
    self.descriptionLabel.text = templateItem.placeholder_description;
    self.templateImageView.image = [UIImage imageNamed:templateItem.placeholder_photo_small];
}

@end
