//
//  MRSLTemplateSelectionCollectionViewCell.h
//  Morsel
//
//  Created by Javier Otero on 8/19/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MRSLBaseCollectionViewCell.h"

@class MRSLTemplate;

@interface MRSLTemplateSelectionCollectionViewCell : MRSLBaseCollectionViewCell

@property (weak, nonatomic) MRSLTemplate *morselTemplate;

@end
