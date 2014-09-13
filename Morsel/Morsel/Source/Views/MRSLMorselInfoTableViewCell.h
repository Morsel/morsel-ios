//
//  MRSLMorselInfoTableViewCell.h
//  Morsel
//
//  Created by Javier Otero on 8/21/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLBaseTableViewCell.h"

@interface MRSLMorselInfoTableViewCell : MRSLBaseTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *keyLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

- (void)alignLabels;

@end
