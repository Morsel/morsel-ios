//
//  PostCollectionViewCell.m
//  Morsel
//
//  Created by Javier Otero on 1/27/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLStoryCollectionViewCell.h"

#import "MRSLMorsel.h"
#import "MRSLPost.h"

@interface MRSLStoryCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *postThumbnailView;
@property (weak, nonatomic) IBOutlet UILabel *postCountLabel;

@end

@implementation MRSLStoryCollectionViewCell

- (void)setPost:(MRSLPost *)post {
    [self reset];

    _post = post;

    self.postTitleLabel.text = _post.title ?: @"No title";

    if ([_post.morsels count] > 0) {
        MRSLMorsel *firstMorsel = [_post.morselsArray firstObject];

        __weak __typeof(self) weakSelf = self;

        if (firstMorsel.morselPhotoURL) {
            [_postThumbnailView setImageWithURLRequest:[firstMorsel morselPictureURLRequestForImageSizeType:MorselImageSizeTypeThumbnail]
                                      placeholderImage:nil
                                               success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
             {
                 if (image) {
                     weakSelf.postThumbnailView.image = image;
                 }
             }
                                               failure:
             ^(NSURLRequest * request, NSHTTPURLResponse * response, NSError * error)
             {
                 DDLogError(@"Unable to set Morsel Thumbnail: %@", error.userInfo);
             }];
        }

        self.postCountLabel.text = [NSString stringWithFormat:@"%lu MORSEL%@", (unsigned long)[_post.morsels count], ([_post.morsels count] > 1) ? @"S" : @""];
    } else {
        DDLogError(@"PostCollectionViewCell assigned a Post with no Morsels. Post ID: %i", [_post.postID intValue]);
        self.postCountLabel.text = @"NO MORSELS";
    }

    [_postCountLabel sizeToFit];
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
    self.postTitleLabel.textColor = selected ? [UIColor whiteColor] : [UIColor morselDarkContent];
    self.postCountLabel.textColor = selected ? [UIColor whiteColor] : [UIColor morselLightContent];

    if (_postThumbnailView.image) {
        self.postThumbnailView.layer.borderColor = [UIColor whiteColor].CGColor;
        self.postThumbnailView.layer.borderWidth = selected ? 2.f : 0.f;
    }
}

- (void)reset {
    self.postThumbnailView.image = nil;
    self.postTitleLabel.text = nil;
    self.postCountLabel.text = nil;
}

@end
