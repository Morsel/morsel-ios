//
//  MorselUploadCollectionViewCell.m
//  Morsel
//
//  Created by Javier Otero on 2/10/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MorselUploadCollectionViewCell.h"

#import "MRSLMorsel.h"

@interface MorselUploadCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;

@end

@implementation MorselUploadCollectionViewCell

#pragma mark - Instance Methods

- (void)awakeFromNib {
    [super awakeFromNib];

    [self.thumbnailImageView setBorderWithColor:[UIColor whiteColor]
                                       andWidth:2.f];
}

- (void)setMorsel:(MRSLMorsel *)morsel {
    if (morsel.morselThumb) {
        self.thumbnailImageView.image = [UIImage imageWithData:morsel.morselThumb];
    }
}

@end
