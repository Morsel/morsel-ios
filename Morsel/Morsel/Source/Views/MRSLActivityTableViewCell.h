//
//  MRSLActivityTableViewCell.h
//  Morsel
//
//  Created by Marty Trzpit on 6/19/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLBaseTableViewCell.h"

@class MRSLActivity;

@interface MRSLActivityTableViewCell : MRSLBaseTableViewCell

@property (weak, nonatomic) MRSLActivity *activity;

@end
