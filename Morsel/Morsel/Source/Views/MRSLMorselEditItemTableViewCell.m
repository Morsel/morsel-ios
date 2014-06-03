//
//  MRSLMorselEditItemTableViewCell.m
//  Morsel
//
//  Created by Javier Otero on 1/28/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLMorselEditItemTableViewCell.h"

#import "MRSLAPIService+Item.h"

#import "MRSLItemImageView.h"

#import "MRSLItem.h"

@interface MRSLMorselEditItemTableViewCell ()

@property (weak, nonatomic) IBOutlet MRSLItemImageView *itemThumbnail;

@property (weak, nonatomic) IBOutlet UILabel *itemDescription;
@property (weak, nonatomic) IBOutlet UIView *failureView;

@end

@implementation MRSLMorselEditItemTableViewCell

#pragma mark - Instance Methods

- (void)awakeFromNib {
    [super awakeFromNib];

    UITapGestureRecognizer *imageTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(displayImagePreview)];
    [_itemThumbnail addGestureRecognizer:imageTapRecognizer];

    UITapGestureRecognizer *textTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(displayTextEdit)];
    [_itemDescription addGestureRecognizer:textTapRecognizer];
}

- (void)setItem:(MRSLItem *)item {
    if (_item != item) [self reset];

    _item = item;

    self.failureView.hidden = !_item.didFailUploadValue;
    _itemDescription.text = (_item.itemDescription.length > 0) ? _item.itemDescription : @"Tap to add text";

    if (_item.itemDescription.length > 0) {
        _itemDescription.textColor = [UIColor morselDarkContent];
    }
    _itemThumbnail.item = _item;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];

    [self displaySelectedState:highlighted];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];

    [self displaySelectedState:selected];
}

- (void)willTransitionToState:(UITableViewCellStateMask)state {
    [super willTransitionToState:state];
    if ([self.delegate respondsToSelector:@selector(morselEditItemCellDidTransitionToDeleteState:)]) {
        [self.delegate morselEditItemCellDidTransitionToDeleteState:(state == UITableViewCellStateShowingDeleteConfirmationMask)];
    }
}

#pragma mark - Action Methods

- (void)displayImagePreview {
    if ([self.delegate respondsToSelector:@selector(morselEditItemCellDidSelectImagePreview:)]) {
        [self.delegate morselEditItemCellDidSelectImagePreview:_item];
    }
}

- (void)displayTextEdit {
    if ([self.delegate respondsToSelector:@selector(morselEditItemCellDidSelectEditText:)]) {
        [self.delegate morselEditItemCellDidSelectEditText:_item];
    }
}

- (IBAction)retryUpload {
    self.item.didFailUpload = @NO;
    self.item.isUploading = @YES;
    if (!_item.itemID) {
        [_appDelegate.apiService createItem:_item
                                        success:^(id responseObject) {
                                            if ([responseObject isKindOfClass:[MRSLItem class]]) {
                                                [_appDelegate.apiService updateItemImage:_item
                                                                                     success:nil
                                                                                     failure:nil];
                                            }
                                        } failure:nil];
    } else {
        [_appDelegate.apiService updateItemImage:_item
                                             success:nil
                                             failure:nil];
    }
}

#pragma mark - Private Methods

- (void)displaySelectedState:(BOOL)selected {
    self.backgroundColor = selected ? [UIColor morselRed] : [UIColor whiteColor];
    self.itemDescription.textColor = selected ? [UIColor whiteColor] : [UIColor morselDarkContent];

    if (_itemThumbnail.image) {
        self.itemThumbnail.layer.borderColor = [UIColor whiteColor].CGColor;
        self.itemThumbnail.layer.borderWidth = selected ? 2.f : 0.f;
    }

    if (_item.itemDescription.length == 0 && !selected) {
        _itemDescription.textColor = [UIColor morselLightContent];
    }
}

- (void)reset {
    self.itemDescription.text = nil;

    _itemDescription.textColor = [UIColor morselLightContent];
}

@end