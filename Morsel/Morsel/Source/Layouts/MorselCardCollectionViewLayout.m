//
//  MorselCardCollectionViewLayout.m
//  Morsel
//
//  Created by Javier Otero on 12/19/13.
//  Copyright (c) 2013 Morsel. All rights reserved.
//

#import "MorselCardCollectionViewLayout.h"

@implementation MorselCardCollectionViewLayout

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self.itemSize = CGSizeMake(320.f, 200.f);
        self.scrollDirection = UICollectionViewScrollDirectionVertical;
    }
    
    return self;
}

@end
