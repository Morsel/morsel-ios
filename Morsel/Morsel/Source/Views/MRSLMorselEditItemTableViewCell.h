//
//  MRSLMorselEditItemTableViewCell.h
//  Morsel
//
//  Created by Javier Otero on 1/28/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MRSLItem;

@protocol MRSLMorselEditItemTableViewCellDelegate <NSObject>

@optional
- (void)morselEditItemCellDidSelectImagePreview:(MRSLItem *)item;
- (void)morselEditItemCellDidSelectEditText:(MRSLItem *)item;
- (void)morselEditItemCellDidTransitionToDeleteState:(BOOL)deleteStateActive;

@end

@interface MRSLMorselEditItemTableViewCell : UITableViewCell

@property (weak, nonatomic) id <MRSLMorselEditItemTableViewCellDelegate> delegate;

@property (strong, nonatomic) MRSLItem *item;

@end
