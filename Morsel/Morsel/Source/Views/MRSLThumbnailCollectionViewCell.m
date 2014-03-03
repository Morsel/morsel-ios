//
//  MorselThumbnailCollectionViewCell.m
//  Morsel
//
//  Created by Javier Otero on 1/24/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLThumbnailCollectionViewCell.h"

#import "MRSLMorsel.h"

@interface MRSLThumbnailCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *thumbnailView;

@end

@implementation MRSLThumbnailCollectionViewCell

- (void)setMorsel:(MRSLMorsel *)morsel {
    if (_morsel != morsel) {
        _morsel = morsel;

        if (_morsel.morselPhotoURL) {
            __weak __typeof(self) weakSelf = self;

            [_thumbnailView setImageWithURLRequest:[_morsel morselPictureURLRequestForImageSizeType:MorselImageSizeTypeThumbnail]
                                    placeholderImage:nil
                                             success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
            {
                if (image) {
                    weakSelf.thumbnailView.image = image;
                }
            } failure: ^(NSURLRequest * request, NSHTTPURLResponse * response, NSError * error) {
                DDLogError(@"Unable to set Morsel Thumbnail: %@", error.userInfo);
            }];
        }
    }
}

- (void)reset {
    [self.thumbnailView cancelImageRequestOperation];

    self.thumbnailView.image = nil;
}

@end
