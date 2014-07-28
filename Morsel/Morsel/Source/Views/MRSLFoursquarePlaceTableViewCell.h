//
//  MRSLFoursquarePlaceTableViewCell.h
//  Morsel
//
//  Created by Javier Otero on 5/29/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLBaseTableViewCell.h"

@class MRSLFoursquarePlace;

@interface MRSLFoursquarePlaceTableViewCell : MRSLBaseTableViewCell

@property (strong, nonatomic) MRSLFoursquarePlace *foursquarePlace;

@end
