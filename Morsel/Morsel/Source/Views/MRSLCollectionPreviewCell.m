//
//  MRSLCollectionPreviewCell.m
//  Morsel
//
//  Created by Javier Otero on 1/27/15.
//  Copyright (c) 2015 Morsel. All rights reserved.
//

#import "MRSLCollectionPreviewCell.h"

#import "MRSLCollection.h"
#import "MRSLItemImageView.h"

@interface MRSLCollectionPreviewCell ()

@property (weak, nonatomic) MRSLItemImageView *itemImageView;

@end

@implementation MRSLCollectionPreviewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [UIColor whiteColor];
}

- (void)setCollection:(MRSLCollection *)collection {
    _collection = collection;
#warning Display collection thumbnail and details
}

@end
