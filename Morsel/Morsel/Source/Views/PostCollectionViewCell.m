//
//  PostCollectionViewCell.m
//  Morsel
//
//  Created by Javier Otero on 1/27/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "PostCollectionViewCell.h"

#import <AFNetworking/UIImageView+AFNetworking.h>

#import "MRSLMorsel.h"
#import "MRSLPost.h"

@interface PostCollectionViewCell ()

@property (nonatomic, weak) IBOutlet UIImageView *postThumbnailView;
@property (nonatomic ,weak) IBOutlet UILabel *postStatusAndCountLabel;

@end

@implementation PostCollectionViewCell

- (void)setPost:(MRSLPost *)post
{
    if (_post != post)
    {
        _post = post;
        
        if (_post &&
            [_post.morsels count] > 0)
        {
            MRSLMorsel *firstMorsel = [_post.morsels firstObject];
            
            if (firstMorsel.isDraft)
            {
                if (firstMorsel.morselThumb)
                {
                    self.postThumbnailView.image = [UIImage imageWithData:firstMorsel.morselThumb];
                }
                else
                {
#warning Determine what text-only thumbnails look like
                }
            }
            else
            {
                __weak __typeof(self)weakSelf = self;
                
                if (firstMorsel.morselPictureURL)
                {
                    [_postThumbnailView setImageWithURLRequest:[firstMorsel morselPictureURLRequestForImageSizeType:MorselImageSizeTypeThumbnail]
                                              placeholderImage:nil
                                                       success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
                     {
                         if (image)
                         {
                             weakSelf.postThumbnailView.image = image;
                         }
                     }
                                                       failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)
                     {
                         DDLogError(@"Unable to set Morsel Thumbnail: %@", error.userInfo);
                     }];
                }
            }
            
            self.postTitleLabel.text = _post.title ? : @"No title";
            
            self.postStatusAndCountLabel.text = [NSString stringWithFormat:@"(%lu morsel%@, %@)", (unsigned long)[_post.morsels count], ([_post.morsels count] > 1) ? @"s" : @"", _post.isDraft ? @"unpublished" : @"published"];
        }
        else
        {
            DDLogError(@"PostCollectionViewCell assigned a Post with no Morsels. Post ID: %i", [_post.postID intValue]);
        }
    }
}

- (void)setHighlighted:(BOOL)highlighted
{
    self.backgroundColor = highlighted ? [UIColor morselRed] : [UIColor whiteColor];
    self.postTitleLabel.textColor = highlighted ? [UIColor whiteColor] : [UIColor morselDarkContent];
    self.postStatusAndCountLabel.textColor = highlighted ? [UIColor morselUserInterface] : [UIColor morselLightContent];
    
    self.postThumbnailView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.postThumbnailView.layer.borderWidth = highlighted ? 2.f : 0.f;
}

@end
