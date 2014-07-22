//
//  MRSLMorselEditItemTableViewCell.m
//  Morsel
//
//  Created by Javier Otero on 1/28/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLMorselEditItemTableViewCell.h"

#import "MRSLAPIService+Item.h"
#import "MRSLS3Service.h"

#import "MRSLItemImageView.h"

#import "MRSLItem.h"

@interface MRSLMorselEditItemTableViewCell ()
<MRSLItemImageViewDelegate>

@property (weak, nonatomic) IBOutlet MRSLItemImageView *itemThumbnail;

@property (weak, nonatomic) IBOutlet UILabel *itemDescription;
@property (weak, nonatomic) IBOutlet UIView *failureView;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView;

@end

@implementation MRSLMorselEditItemTableViewCell

#pragma mark - Instance Methods

- (void)setItem:(MRSLItem *)item {
    if (_item != item) [self reset];

    _item = item;

    self.failureView.hidden = !_item.didFailUploadValue;
    _itemDescription.text = (_item.itemDescription.length > 0) ? _item.itemDescription : @"Tap to edit item";

    if (_item.itemDescription.length > 0) {
        _itemDescription.textColor = [UIColor morselDarkContent];
    }
    _itemThumbnail.item = _item;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [self displaySelectedState:highlighted];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [self displaySelectedState:selected];
}

- (void)willTransitionToState:(UITableViewCellStateMask)state {
    [super willTransitionToState:state];
    if ([self.delegate respondsToSelector:@selector(morselEditItemCellDidTransitionToDeleteState:)]) {
        [self.delegate morselEditItemCellDidTransitionToDeleteState:(state == UITableViewCellStateShowingDeleteConfirmationMask)];
    }
}

#pragma mark - Action Methods

- (IBAction)retryUpload {
    self.item.didFailUpload = @NO;
    self.item.isUploading = @YES;
    __weak __typeof(self) weakSelf = self;
    if (!_item.itemID) {
        [_appDelegate.apiService createItem:_item
                                        success:^(id responseObject) {
                                            if ([responseObject isKindOfClass:[MRSLItem class]]) {
                                                //  If presignedUpload returned, use it, otherwise fallback to old upload method
                                                if (weakSelf.item.presignedUpload) {
                                                    [_appDelegate.s3Service uploadImageData:_item.itemPhotoFull
                                                                         forPresignedUpload:_item.presignedUpload
                                                                                    success:^(NSDictionary *responseDictionary) {
                                                                                        [_appDelegate.apiService updatePhotoKey:responseDictionary[@"Key"]
                                                                                                                        forItem:weakSelf.item
                                                                                                                        success:nil
                                                                                                                        failure:nil];
                                                                                    } failure:^(NSError *error) {
                                                                                        //  S3 upload failed, fallback to API upload
                                                                                        [_appDelegate.apiService updateItemImage:weakSelf.item
                                                                                                                         success:nil
                                                                                                                         failure:nil];
                                                                                    }];
                                                } else {
                                                    [_appDelegate.apiService updateItemImage:weakSelf.item
                                                                                     success:nil
                                                                                     failure:nil];
                                                }
                                            }
                                        } failure:nil];
    } else {
        //  If presignedUpload returned, use it, otherwise fallback to old upload method
        if (_item.presignedUpload) {
            [_appDelegate.s3Service uploadImageData:_item.itemPhotoFull
                                 forPresignedUpload:_item.presignedUpload
                                            success:^(NSDictionary *responseDictionary) {
                                                [_appDelegate.apiService updatePhotoKey:responseDictionary[@"Key"]
                                                                                forItem:weakSelf.item
                                                                                success:nil
                                                                                failure:nil];
                                            } failure:^(NSError *error) {
                                                //  S3 upload failed, fallback to API upload
                                                [_appDelegate.apiService updateItemImage:weakSelf.item
                                                                                 success:nil
                                                                                 failure:nil];
                                            }];
        } else {
            [_appDelegate.apiService updateItemImage:_item
                                             success:nil
                                             failure:nil];
        }
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

    if (self.arrowImageView) {
        self.arrowImageView.image = [UIImage imageNamed:(selected) ? @"icon-arrow-accessory-white" : @"icon-arrow-accessory-red"];
    }
}

- (void)reset {
    self.itemDescription.text = nil;

    _itemDescription.textColor = [UIColor morselLightContent];
}

@end
