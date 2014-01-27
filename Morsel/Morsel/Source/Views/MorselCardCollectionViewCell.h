//
//  MorselCardCollectionViewCell.h
//  Morsel
//
//  Created by Javier Otero on 12/13/13.
//  Copyright (c) 2013 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MorselCardCollectionViewCell, MRSLMorsel;

@protocol MorselCardCollectionViewCellDelegate <NSObject>

@required
- (void)morselCardDidSelectAddMedia:(MorselCardCollectionViewCell *)card;
- (void)morselCard:(MorselCardCollectionViewCell *)card didUpdateDescription:(NSString *)description;
- (void)morselCardDidBeginEditing:(MorselCardCollectionViewCell *)card;

@end

@interface MorselCardCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) id <MorselCardCollectionViewCellDelegate> delegate;
@property (nonatomic, weak) MRSLMorsel *morsel;

- (void)updateMedia:(UIImage *)media;

@end
