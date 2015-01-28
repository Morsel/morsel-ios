//
//  MRSLPROTitleTextViewTableViewCell.m
//  Morsel
//
//  Created by Marty Trzpit on 1/28/15.
//  Copyright (c) 2015 Morsel. All rights reserved.
//

#import "MRSLPROTitleTextViewTableViewCell.h"

#import "MRSLPROTextView.h"

@interface MRSLPROExpandableTextTableViewCell()

@property (nonatomic, weak) IBOutlet MRSLPROTextView *textView;
- (CGFloat)minimumHeight;

@end

@interface MRSLPROTitleTextViewTableViewCell()

@property (nonatomic, weak) IBOutlet UIImageView *primaryItemPhotoImageView;

@end

@implementation MRSLPROTitleTextViewTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];

    [self.textView setFont:[UIFont primaryBoldFontOfSize:self.textView.font.pointSize]];
    [self.textView setTextContainerInset:UIEdgeInsetsMake((MRSLPRODefaultTitleCellHeight * 0.5f) - self.textView.font.pointSize, 0.0f, self.textView.font.pointSize, 0.0f)];

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.textView addStandardShadow];
        [self.textView setTextColor:[UIColor whiteColor]];
    });
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.primaryItemPhotoImageView.frame = self.frame;
    [self.primaryItemPhotoImageView setBackgroundColor:[UIColor magentaColor]];
}


#pragma mark - Private Methods

- (CGFloat)minimumHeight {
    return MRSLPRODefaultTitleCellHeight;
}

@end
