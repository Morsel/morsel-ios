//
//  MRSLImagePreviewCollectionViewCell.m
//  Morsel
//
//  Created by Javier Otero on 3/7/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLImagePreviewCollectionViewCell.h"

#import <AFNetworking/AFNetworking.h>

#import "MRSLMediaItem.h"
#import "MRSLMorsel.h"

@interface MRSLImagePreviewCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *previewImageView;

@property (strong, nonatomic) AFHTTPRequestOperation *imageRequestOperation;

@end

@implementation MRSLImagePreviewCollectionViewCell

- (void)setMediaPreviewItem:(id)mediaPreviewItem {
    if (_mediaPreviewItem != mediaPreviewItem) {
        [self reset];

        _mediaPreviewItem = mediaPreviewItem;
        if ([mediaPreviewItem isKindOfClass:[MRSLMorsel class]]) {
            MRSLMorsel *morsel = (MRSLMorsel *)mediaPreviewItem;
            if (morsel.morselPhotoURL) {
                NSURLRequest *profileImageURLRequest = [morsel morselPictureURLRequestForImageSizeType:MorselImageSizeTypeFull];
                if (profileImageURLRequest) {
                    __weak __typeof(self)weakSelf = self;

                    self.imageRequestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:profileImageURLRequest];
                    [_imageRequestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, NSData *imageData)
                     {
                         UIImage *downloadedProfileImage = [UIImage imageWithData:imageData];
                         weakSelf.previewImageView.image = downloadedProfileImage;

                         weakSelf.imageRequestOperation = nil;
                     } failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
                         DDLogError(@"Preview Media Image Request Failed: %@", error.userInfo);
                         weakSelf.imageRequestOperation = nil;
                     }];

                    [_imageRequestOperation start];
                }
            } else {
                self.previewImageView.image = [UIImage imageWithData:morsel.morselPhotoCropped];
            }
        } else if ([mediaPreviewItem isKindOfClass:[MRSLMediaItem class]]) {
            MRSLMediaItem *mediaItem = (MRSLMediaItem *)mediaPreviewItem;
            self.previewImageView.image = mediaItem.mediaCroppedImage;
        }
    }
}

#pragma mark - Reset

- (void)reset {
    if (self.imageRequestOperation) {
        [self.imageRequestOperation cancel];
        self.imageRequestOperation = nil;
    }
    self.previewImageView.image = nil;
}

#pragma mark - Destruction Methods

- (void)dealloc {
    [self reset];
}

@end