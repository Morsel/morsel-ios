//
//  MorselUploadFailureCollectionViewCell.m
//  Morsel
//
//  Created by Javier Otero on 2/10/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MorselUploadFailureCollectionViewCell.h"

#import "MRSLMorsel.h"

@interface MorselUploadFailureCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIButton *retryButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;

@end

@implementation MorselUploadFailureCollectionViewCell

#pragma mark - Instance Methods

- (void)awakeFromNib {
    [super awakeFromNib];

    [self.thumbnailImageView setBorderWithColor:[UIColor whiteColor]
                                       andWidth:2.f];
}

- (void)setMorsel:(MRSLMorsel *)morsel {
    if (morsel.morselThumb) {
        self.thumbnailImageView.image = [UIImage imageWithData:morsel.morselThumb];
    }
}

#pragma mark - Action

- (IBAction)retryUpload {
    [_appDelegate.morselApiService createMorsel:_morsel
                                        success:nil
                                        failure:nil];
}

- (IBAction)deleteMorsel {
    [_morsel MR_deleteEntity];
}

@end
