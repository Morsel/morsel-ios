//
//  PostMorselCollectionViewCell.m
//  Morsel
//
//  Created by Javier Otero on 1/28/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "PostMorselCollectionViewCell.h"

#import "MRSLMorsel.h"

@interface PostMorselCollectionViewCell ()

@property (nonatomic, weak) IBOutlet UILabel *morselDescription;
@property (nonatomic, weak) IBOutlet UIImageView *morselThumbnail;

@end

@implementation PostMorselCollectionViewCell

- (void)setMorsel:(MRSLMorsel *)morsel {
    if (_morsel != morsel) {
        [self reset];

        _morsel = morsel;

        if (_morsel) {
            _morselDescription.text = (_morsel.morselDescription.length > 0) ? _morsel.morselDescription : @"No description";

            if (_morsel.morselDescription.length > 0) {
                _morselDescription.textColor = [UIColor morselDarkContent];
            }

            if (_morsel.isDraft) {
                if (_morsel.morselThumb) {
                    self.morselThumbnail.image = [UIImage imageWithData:_morsel.morselThumb];
                } else {
                }
            } else {
                __weak __typeof(self) weakSelf = self;

                if (_morsel.morselPictureURL) {
                    [_morselThumbnail setImageWithURLRequest:[_morsel morselPictureURLRequestForImageSizeType:MorselImageSizeTypeThumbnail]
                                              placeholderImage:nil
                                                       success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
                    {
                        if (image) {
                            weakSelf.morselThumbnail.image = image;
                        }
                    }
                failure:
                    ^(NSURLRequest * request, NSHTTPURLResponse * response, NSError * error)
                    {
                        DDLogError(@"Unable to set Morsel Thumbnail: %@", error.userInfo);
                    }];
                }
            }
        }
    }
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];

    [self displaySelectedState:highlighted];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];

    [self displaySelectedState:selected];
}

- (void)displaySelectedState:(BOOL)selected {
    self.backgroundColor = selected ? [UIColor morselRed] : [UIColor whiteColor];
    self.morselDescription.textColor = selected ? [UIColor whiteColor] : [UIColor morselDarkContent];

    if (_morselThumbnail.image) {
        self.morselThumbnail.layer.borderColor = [UIColor whiteColor].CGColor;
        self.morselThumbnail.layer.borderWidth = selected ? 2.f : 0.f;
    }
}

- (void)reset {
    self.morselThumbnail.image = nil;
    self.morselDescription.text = nil;

    _morselDescription.textColor = [UIColor morselLightContent];
}

@end
