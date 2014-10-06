//
//  MRSLEligibleUserTableViewCell.h
//  Morsel
//
//  Created by Javier Otero on 10/8/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLBaseTableViewCell.h"

@interface MRSLEligibleUserTableViewCell : MRSLBaseTableViewCell

@property (weak, nonatomic) IBOutlet UIView *pipeView;

- (void)setUser:(MRSLUser *)user
      andMorsel:(MRSLMorsel *)morsel;

@end
