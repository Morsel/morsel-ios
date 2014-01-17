//
//  MorselScrollView.m
//  Morsel
//
//  Created by Javier Otero on 12/13/13.
//  Copyright (c) 2013 Morsel. All rights reserved.
//

#import "MorselScrollView.h"

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
            
            if (morsel.morselPicture)
            {
                UIImageView *morselImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.f + (320.f * idx), 0.f, 320.f, 200.f)];
                UIImage *morselImage = [UIImage imageWithData:morsel.morselPicture];
                
                morselImageView.contentMode = UIViewContentModeScaleAspectFill;
                morselImageView.image = morselImage;
                
                [self addSubview:morselImageView];
                
                [self setContentSize:CGSizeMake(320.f * (idx + 1), 200.f)];
            }
        }];
    }
}

- (void)reset
{
    self.post = nil;
    
    [[self subviews] enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop)
    {
        [subview removeFromSuperview];
    }];
}

@end
