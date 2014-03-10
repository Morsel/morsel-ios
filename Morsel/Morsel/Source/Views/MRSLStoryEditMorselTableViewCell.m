//
//  PostMorselCollectionViewCell.m
//  Morsel
//
//  Created by Javier Otero on 1/28/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLStoryEditMorselTableViewCell.h"

#import "MRSLMorsel.h"

@interface MRSLStoryEditMorselTableViewCell ()

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *morselDescription;
@property (weak, nonatomic) IBOutlet UIImageView *morselThumbnail;
@property (weak, nonatomic) IBOutlet UIView *activityView;
@property (weak, nonatomic) IBOutlet UIView *failureView;

@end

@implementation MRSLStoryEditMorselTableViewCell

#pragma mark - Instance Methods

- (void)awakeFromNib {
    [super awakeFromNib];

    UITapGestureRecognizer *imageTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(displayImagePreview)];
    [_morselThumbnail addGestureRecognizer:imageTapRecognizer];

    UITapGestureRecognizer *textTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(displayTextEdit)];
    [_morselDescription addGestureRecognizer:textTapRecognizer];

    [self setEditingAccessoryView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon-edit.png"]]];
}

- (void)setMorsel:(MRSLMorsel *)morsel {
    [self reset];

    _morsel = morsel;

    if (_morsel) {
        self.activityView.hidden = !_morsel.isUploadingValue;
        (_morsel.isUploadingValue) ? [self.activityIndicator startAnimating] : [self.activityIndicator stopAnimating];
        self.failureView.hidden = !_morsel.didFailUploadValue;
        _morselDescription.text = (_morsel.morselDescription.length > 0) ? _morsel.morselDescription : @"Tap to add text";

        if (_morsel.morselDescription.length > 0) {
            _morselDescription.textColor = [UIColor morselDarkContent];
        }

        __weak __typeof(self) weakSelf = self;

        if (_morsel.morselPhotoURL) {
            [_morselThumbnail setImageWithURLRequest:[_morsel morselPictureURLRequestForImageSizeType:MorselImageSizeTypeThumbnail]
                                    placeholderImage:nil
                                             success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                 if (image) {
                                                     weakSelf.morselThumbnail.image = image;
                                                 }
                                             } failure:^(NSURLRequest * request, NSHTTPURLResponse * response, NSError * error) {
                                                 if (weakSelf.morsel.morselPhotoThumb) {
                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                         weakSelf.morselThumbnail.image = [UIImage imageWithData:weakSelf.morsel.morselPhotoThumb];
                                                     });
                                                 } else {
                                                     DDLogError(@"Unable to set Morsel thumbnail and no local image exists: %@", error.userInfo);
                                                     weakSelf.morselThumbnail.image = nil;
                                                 }
                                             }];
        } else {
            if (_morsel.morselPhotoThumb) {
                self.morselThumbnail.image = [UIImage imageWithData:_morsel.morselPhotoThumb];
            } else {
                self.morselThumbnail.image = nil;
            }
        }
    }
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];

    [self displaySelectedState:highlighted];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];

    [self displaySelectedState:selected];
}


#pragma mark - Action Methods

- (void)displayImagePreview {
    if ([self.delegate respondsToSelector:@selector(morselCollectionViewDidSelectImagePreview:)]) {
        [self.delegate morselCollectionViewDidSelectImagePreview:_morsel];
    }
}

- (void)displayTextEdit {
    if ([self.delegate respondsToSelector:@selector(morselCollectionViewDidSelectEditText:)]) {
        [self.delegate morselCollectionViewDidSelectEditText:_morsel];
    }
}

- (IBAction)retryUpload {
    self.morsel.didFailUpload = @NO;
    self.morsel.isUploading = @YES;
    [_appDelegate.morselApiService createMorsel:_morsel
                                        success:nil
                                        failure:nil];
}

#pragma mark - Private Methods

- (void)displaySelectedState:(BOOL)selected {
    self.backgroundColor = selected ? [UIColor morselRed] : [UIColor whiteColor];
    self.morselDescription.textColor = selected ? [UIColor whiteColor] : [UIColor morselDarkContent];

    if (_morselThumbnail.image) {
        self.morselThumbnail.layer.borderColor = [UIColor whiteColor].CGColor;
        self.morselThumbnail.layer.borderWidth = selected ? 2.f : 0.f;
    }
    
    if (_morsel.morselDescription.length == 0 && !selected) {
        _morselDescription.textColor = [UIColor morselLightContent];
    }
}

- (void)reset {
    self.morselThumbnail.image = nil;
    self.morselDescription.text = nil;
    
    _morselDescription.textColor = [UIColor morselLightContent];
}

@end
