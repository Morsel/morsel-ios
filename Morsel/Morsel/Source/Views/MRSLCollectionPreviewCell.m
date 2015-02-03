//
//  MRSLCollectionPreviewCell.m
//  Morsel
//
//  Created by Javier Otero on 1/27/15.
//  Copyright (c) 2015 Morsel. All rights reserved.
//

#import "MRSLCollectionPreviewCell.h"

#import "MRSLItemImageView.h"
#import "MRSLStandardTextView.h"

#import "MRSLCollection.h"
#import "MRSLMorsel.h"

@interface MRSLCollectionPreviewCell ()

@property (weak, nonatomic) IBOutlet UIView *imageContainerView;

@property (weak, nonatomic) IBOutlet MRSLStandardTextView *textView;

@property (strong, nonatomic) IBOutletCollection(MRSLItemImageView) NSArray *imageViews;

@end

@implementation MRSLCollectionPreviewCell

#pragma mark - Instance Methods

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [UIColor morselBackgroundDark];
    self.textView.backgroundColor = [UIColor clearColor];

    self.imageViews =  [_imageViews sortedArrayUsingComparator:^NSComparisonResult(MRSLItemImageView *imageViewA, MRSLItemImageView *imageViewB) {
        return [imageViewA tag] > [imageViewB tag];
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    if (!self.imageContainerView.layer.mask) {
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.frame = self.bounds;
        gradientLayer.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:1.f
                                                                              green:1.f
                                                                               blue:1.f
                                                                              alpha:1.f] CGColor],
                                (id)[[UIColor colorWithRed:1.f
                                                     green:1.f
                                                      blue:1.f
                                                     alpha:0.f] CGColor], nil];

        gradientLayer.startPoint = CGPointMake(0.f, 0.5f);
        gradientLayer.endPoint = CGPointMake(0.f, 1.f);

        self.imageContainerView.layer.mask = gradientLayer;
    } else {
        self.imageContainerView.layer.mask.frame = self.bounds;
    }
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    self.contentView.frame = bounds;
}

#pragma mark - Setter Methods

- (void)setCollection:(MRSLCollection *)collection {
    _collection = collection;
    [self.imageViews enumerateObjectsUsingBlock:^(MRSLItemImageView *imageView, NSUInteger idx, BOOL *stop) {
        if (idx < [collection.morsels count]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                imageView.item = [[collection.morselsArray objectAtIndex:idx] coverItem];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                imageView.item = nil;
            });
        }
    }];
    self.textView.attributedText = [collection thumbnailInformation];
}

@end
