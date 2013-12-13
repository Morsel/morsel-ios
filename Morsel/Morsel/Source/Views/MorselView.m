//
//  MorselView.m
//  Morsel
//
//  Created by Javier Otero on 12/13/13.
//  Copyright (c) 2013 Morsel. All rights reserved.
//

#import "MorselView.h"

#import "MorselScrollView.h"
#import "ProfileImageView.h"

#import "MRSLMorsel.h"
#import "MRSLPost.h"
#import "MRSLUser.h"

@interface MorselView ()

#pragma mark - Private Properties

@property (nonatomic, weak) IBOutlet UIButton *likeButton;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;

@property (nonatomic, weak) IBOutlet MorselScrollView *morselScrollView;
@property (nonatomic, weak) IBOutlet ProfileImageView *profileImageView;

@end

@implementation MorselView

#pragma mark - Instance Methods

- (void)setPost:(MRSLPost *)post
{
    _post = post;
    
    if (_post)
    {
        MRSLMorsel *morsel = [_post.morsels objectAtIndex:0];
        
        self.titleLabel.text = _post.title;
        self.descriptionLabel.text = morsel.morselDescription;
        
        self.profileImageView.user = _post.author;
        
        self.morselScrollView.post = _post;
    }
}

- (void)reset
{
    self.titleLabel.text = nil;
    self.descriptionLabel.text = nil;
    self.post = nil;
    self.profileImageView.user = nil;
    
    [self.morselScrollView reset];
}

@end
