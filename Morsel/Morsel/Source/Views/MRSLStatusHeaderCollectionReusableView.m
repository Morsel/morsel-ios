//
//  MRSLStatusHeaderCollectionReusableView.m
//  Morsel
//
//  Created by Javier Otero on 3/3/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLStatusHeaderCollectionReusableView.h"

@implementation MRSLStatusHeaderCollectionReusableView

#pragma mark - Action Methods

- (IBAction)viewAll
{
    if ([self.delegate respondsToSelector:@selector(statusHeaderDidSelectViewAllForType:)]) {
        [self.delegate statusHeaderDidSelectViewAllForType:([self.statusLabel.text isEqualToString:@"Drafts"]) ? MRSLStoryStatusTypeDrafts : MRSLStoryStatusTypePublished];
    }
}

@end
