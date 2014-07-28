//
//  MRSLUserFollowTableViewCell.h
//  Morsel
//
//  Created by Javier Otero on 4/30/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLBaseTableViewCell.h"

@interface MRSLUserFollowTableViewCell : MRSLBaseTableViewCell

@property (weak, nonatomic) IBOutlet UIView *pipeView;

@property (weak, nonatomic) MRSLUser *user;

@end
