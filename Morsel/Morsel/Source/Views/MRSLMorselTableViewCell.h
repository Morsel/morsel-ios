//
//  MRSLMorselTableViewCell.h
//  Morsel
//
//  Created by Javier Otero on 7/8/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLBaseTableViewCell.h"

@interface MRSLMorselTableViewCell : MRSLBaseTableViewCell

@property (weak, nonatomic) MRSLMorsel *morsel;

@property (weak, nonatomic) IBOutlet UILabel *morselTitleLabel;
@property (weak, nonatomic) IBOutlet UIView *morselPipeView;

@end
