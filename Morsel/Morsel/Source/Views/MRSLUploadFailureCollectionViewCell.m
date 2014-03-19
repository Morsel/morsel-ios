//
//  MorselUploadFailureCollectionViewCell.m
//  Morsel
//
//  Created by Javier Otero on 2/10/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLUploadFailureCollectionViewCell.h"

#import "MRSLMorsel.h"

@interface MRSLUploadFailureCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIButton *retryButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;

@end

@implementation MRSLUploadFailureCollectionViewCell

#pragma mark - Instance Methods

- (void)awakeFromNib {
    [super awakeFromNib];

    [self.thumbnailImageView setBorderWithColor:[UIColor whiteColor]
                                       andWidth:2.f];
}

- (void)setMorsel:(MRSLMorsel *)morsel {
    if (_morsel != morsel) {
        [self reset];
        _morsel = morsel;
        if (_morsel.morselPhotoThumb) {
            self.thumbnailImageView.image = [UIImage imageWithData:_morsel.morselPhotoThumb];
        } else {
            self.thumbnailImageView.image = nil;
        }
    }
}

#pragma mark - Action

- (IBAction)retryUpload {
    [self reset];
    _morsel.didFailUpload = @NO;
    _morsel.isUploading = @YES;
    [_appDelegate.morselApiService updateMorselImage:_morsel
                                             success:nil
                                             failure:nil];
}

- (IBAction)deleteMorsel {
    [self reset];
    __weak __typeof(self) weakSelf = self;
    [_appDelegate.morselApiService deleteMorsel:_morsel
                                        success:nil
                                        failure:^(NSError *error) {
                                            if (weakSelf) {
                                                weakSelf.retryButton.enabled = NO;
                                                weakSelf.deleteButton.enabled = NO;
                                            }
                                        }];
}

#pragma mark - Private Methods

- (void)reset {
    _retryButton.enabled = NO;
    _deleteButton.enabled = NO;
}

@end
