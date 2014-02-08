//
//  PostCollectionViewCell.m
//  Morsel
//
//  Created by Javier Otero on 1/27/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "PostCollectionViewCell.h"

#import "MRSLMorsel.h"
#import "MRSLPost.h"

@interface PostCollectionViewCell ()

@property (nonatomic, weak) IBOutlet UIImageView *postThumbnailView;
@property (nonatomic, weak) IBOutlet UILabel *postCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *postStatusLabel;
@property (weak, nonatomic) IBOutlet UIImageView *postCheckmark;

@end

@implementation PostCollectionViewCell

- (void)setPost:(MRSLPost *)post {
    if (_post != post) {
        [self reset];

        _post = post;

        if (_post &&
            [_post.morsels count] > 0) {
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

            self.postTitleLabel.text = _post.title ?: @"No title";

            self.postCountLabel.text = [NSString stringWithFormat:@"%lu MORSEL%@ |", (unsigned long)[_post.morsels count], ([_post.morsels count] > 1) ? @"S" : @""];

            self.postStatusLabel.text = _post.isPublished ? @"PUBLISHED" : @"UNPUBLISHED";
            self.postStatusLabel.textColor = _post.isPublished ? [UIColor morselGreen] : [UIColor morselRed];

            [_postCountLabel sizeToFit];
            [_postStatusLabel sizeToFit];

            [_postStatusLabel setX:[_postCountLabel getX] + [_postCountLabel getWidth] + 5.f];
        } else {
            DDLogError(@"PostCollectionViewCell assigned a Post with no Morsels. Post ID: %i", [_post.postID intValue]);
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
    self.postCheckmark.image = [UIImage imageNamed:selected ? @"icon-checkmark-on" : @"icon-checkmark-off"];
}

- (void)reset {
    self.postThumbnailView.image = nil;
    self.postTitleLabel.text = nil;
    self.postCountLabel.text = nil;
    self.postStatusLabel.text = nil;
}

@end
