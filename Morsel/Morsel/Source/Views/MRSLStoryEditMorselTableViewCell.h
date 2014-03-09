//
//  PostMorselCollectionViewCell.h
//  Morsel
//
//  Created by Javier Otero on 1/28/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MRSLMorsel;

@protocol MRSLStoryEditMorselTableViewCellDelegate <NSObject>

@optional
- (void)morselCollectionViewDidSelectImagePreview:(MRSLMorsel *)morsel;
- (void)morselCollectionViewDidSelectEditText:(MRSLMorsel *)morsel;

@end

@interface MRSLStoryEditMorselTableViewCell : UITableViewCell

@property (weak, nonatomic) id <MRSLStoryEditMorselTableViewCellDelegate> delegate;

@property (strong, nonatomic) MRSLMorsel *morsel;

@end
