//
//  MorselScrollView.m
//  Morsel
//
//  Created by Javier Otero on 12/13/13.
//  Copyright (c) 2013 Morsel. All rights reserved.
//

#import "MorselScrollView.h"

#import <AFNetworking/UIImageView+AFNetworking.h>

#import "MRSLMorsel.h"
#import "MRSLPost.h"

@interface MorselScrollView ()

@end

@implementation MorselScrollView

#pragma mark - Public Methods

- (void)setPost:(MRSLPost *)post
{
    _post = post;
    
    if (_post)
    {
        [_post.morsels enumerateObjectsUsingBlock:^(MRSLMorsel *morsel, NSUInteger idx, BOOL *stop)
        {
            if ([morsel.morselDescription length] > 0)
            {
#warning Populate text version
            }
            
            if (morsel.morselPictureURL)
            {
                UIImageView *morselImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.f + (320.f * idx), 0.f, 320.f, 200.f)];
                morselImageView.contentMode = UIViewContentModeScaleAspectFill;
                
                [self addSubview:morselImageView];
                [self setContentSize:CGSizeMake(320.f * (idx + 1), 200.f)];
                
                if (morsel.morselPicture)
                {
                    UIImage *morselImage = [UIImage imageWithData:morsel.morselPicture];
                    morselImageView.image = morselImage;
                }
                
                if (morsel.morselPictureURL && !morsel.morselPicture)
                {
                    __weak UIImageView *weakImageView = morselImageView;
                    
                    [morselImageView setImageWithURLRequest:morsel.morselPictureURLRequest
                                            placeholderImage:nil
                                                     success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
                     {
                         if (image)
                         {
                             __strong UIImageView *strongImageView = weakImageView;
                             strongImageView.image = image;
                         }
                     }
                                                     failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)
                     {
                         DDLogError(@"Unable to set Morsel Image in ScrollView: %@", error.userInfo);
                     }];
                }
            }
        }];
    }
}

- (void)scrollToMorsel:(MRSLMorsel *)morsel
{
    int morselIndex = [_post.morsels indexOfObject:morsel];
    
    [self scrollRectToVisible:CGRectMake(self.frame.size.width * morselIndex, 0.f, self.frame.size.width, self.frame.size.height)
                     animated:NO];
}

- (void)reset
{
    self.post = nil;
    
    [[self subviews] enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop)
    {
        if ([subview isKindOfClass:[UIImageView class]])
        {
            UIImageView *imageView = (UIImageView *)subview;
            [imageView cancelImageRequestOperation];
        }
        
        [subview removeFromSuperview];
    }];
}

#pragma mark - Private Methods

- (void)dealloc
{
    [self reset];
}

@end
