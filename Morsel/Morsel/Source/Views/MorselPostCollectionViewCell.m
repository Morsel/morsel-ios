//
//  MorselPostCollectionViewCell.m
//  Morsel
//
//  Created by Javier Otero on 12/13/13.
//  Copyright (c) 2013 Morsel. All rights reserved.
//

#import "MorselPostCollectionViewCell.h"

#import "MorselView.h"

@interface MorselPostCollectionViewCell ()

@property (nonatomic, weak) IBOutlet MorselView *morselView;

@end

@implementation MorselPostCollectionViewCell

#pragma mark - Instance Methods

- (void)setPost:(MRSLPost *)post
{
    [self reset];
    
    self.morselView.post = post;
}

- (void)reset
{
    [self.morselView reset];
}

@end
