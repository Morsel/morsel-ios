//
//  MRSLToggleKeywordTableViewCell.h
//  Morsel
//
//  Created by Javier Otero on 5/1/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MRSLToggleKeywordTableViewCell : UITableViewCell

@property (weak, nonatomic) MRSLKeyword *keyword;

@property (weak, nonatomic) IBOutlet UIView *pipeView;

@end
