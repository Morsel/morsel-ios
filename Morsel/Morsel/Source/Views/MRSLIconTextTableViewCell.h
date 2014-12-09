//
//  MRSLIconTextTableViewCell.h
//  Morsel
//
//  Created by Javier Otero on 12/12/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLBaseTableViewCell.h"

@interface MRSLIconTextTableViewCell : MRSLBaseTableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end
