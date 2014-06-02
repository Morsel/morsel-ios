//
//  MRSLFollowButton.h
//  Morsel
//
//  Created by Javier Otero on 5/28/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLColoredBackgroundLightButton.h"

@interface MRSLFollowButton : MRSLColoredBackgroundLightButton

@property (weak, nonatomic) MRSLUser *user;
@property (weak, nonatomic) MRSLPlace *place;

@end
