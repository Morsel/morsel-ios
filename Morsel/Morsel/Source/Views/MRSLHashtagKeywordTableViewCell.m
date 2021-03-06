//
//  MRSLHashtagKeywordTableViewCell.m
//  Morsel
//
//  Created by Javier Otero on 12/9/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLHashtagKeywordTableViewCell.h"

#import "MRSLKeyword.h"

@interface MRSLHashtagKeywordTableViewCell ()

@property (nonatomic, weak) IBOutlet UILabel *hashtagLabel;
@property (weak, nonatomic) IBOutlet UILabel *hashtagCountLabel;
@property (nonatomic, weak) IBOutlet UIImageView *arrowImageView;

@end

@implementation MRSLHashtagKeywordTableViewCell

- (void)awakeFromNib {
    if (_hashtagKeyword) {
        [self populateContent];
    }
}

- (void)setHashtagKeyword:(MRSLKeyword *)hashtagKeyword {
    _hashtagKeyword = hashtagKeyword;
    [self populateContent];
}

- (void)populateContent {
    self.hashtagLabel.text = [NSString stringWithFormat:@"#%@", _hashtagKeyword.name];
    self.hashtagCountLabel.text = [NSString stringWithFormat:@"%i morsel%@", _hashtagKeyword.tags_countValue, (_hashtagKeyword.tags_countValue > 1) ? @"s" : @""];
}

@end
