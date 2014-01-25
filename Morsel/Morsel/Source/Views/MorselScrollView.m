//
//  MorselScrollView.m
//  Morsel
//
//  Created by Javier Otero on 12/13/13.
//  Copyright (c) 2013 Morsel. All rights reserved.
//

#import "MorselScrollView.h"

#import "MorselDetailPanelViewController.h"

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
            MorselDetailPanelViewController *morselDetailPanelVC = [[UIStoryboard mainStoryboard] instantiateViewControllerWithIdentifier:@"MorselDetailPanel"];
            morselDetailPanelVC.view.frame = CGRectMake(0.f + (320.f * idx), 0.f, 320.f, self.frame.size.height);
            morselDetailPanelVC.morsel = morsel;
            
            [self addSubview:morselDetailPanelVC.view];
            [self setContentSize:CGSizeMake(320.f * (idx + 1), 200.f)];
        }];
    }
}

- (void)scrollToMorsel:(MRSLMorsel *)morsel
{
    NSUInteger morselIndex = [_post.morsels indexOfObject:morsel];
    
    [self scrollRectToVisible:CGRectMake(self.frame.size.width * morselIndex, 0.f, self.frame.size.width, 1.f)
                     animated:NO];
}

- (void)reset
{
    self.post = nil;
    
    [[self subviews] enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop)
    {
        [subview removeFromSuperview];
    }];
}

#pragma mark - Private Methods

- (void)dealloc
{
    [self reset];
}

@end
