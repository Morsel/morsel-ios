//
//  MRSLTemplateInfoTableViewCell.h
//  Morsel
//
//  Created by Javier Otero on 8/20/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLBaseTableViewCell.h"

@class MRSLTemplateItem;

@interface MRSLTemplateItemInfoTableViewCell : MRSLBaseTableViewCell

@property (weak, nonatomic) MRSLTemplateItem *templateItem;

@end
