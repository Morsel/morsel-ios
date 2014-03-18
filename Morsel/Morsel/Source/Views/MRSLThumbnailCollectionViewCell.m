//
//  MorselThumbnailCollectionViewCell.m
//  Morsel
//
//  Created by Javier Otero on 1/24/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLThumbnailCollectionViewCell.h"

#import "MRSLMorselImageView.h"

#import "MRSLMorsel.h"

@interface MRSLThumbnailCollectionViewCell ()

@property (weak, nonatomic) IBOutlet MRSLMorselImageView *thumbnailView;

@end

@implementation MRSLThumbnailCollectionViewCell

- (void)setMorsel:(MRSLMorsel *)morsel {
    if (_morsel != morsel) {
        _morsel = morsel;
        _thumbnailView.morsel = _morsel;
    }
}

@end
