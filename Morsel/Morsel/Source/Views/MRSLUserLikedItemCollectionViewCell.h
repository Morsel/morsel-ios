//
//  MRSLUserLikedItemCollectionViewCell.h
//  Morsel
//
//  Created by Javier Otero on 5/6/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLBaseCollectionViewCell.h"

@interface MRSLUserLikedItemCollectionViewCell : MRSLBaseCollectionViewCell

- (void)setItem:(MRSLItem *)item
        andUser:(MRSLUser *)user;

@end
