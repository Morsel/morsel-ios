//
//  MRSLToggleKeywordTableViewCell.h
//  Morsel
//
//  Created by Javier Otero on 5/1/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLBaseTableViewCell.h"

@interface MRSLToggleKeywordTableViewCell : MRSLBaseTableViewCell

@property (weak, nonatomic) MRSLKeyword *keyword;

@property (weak, nonatomic) IBOutlet UIView *pipeView;

@end
