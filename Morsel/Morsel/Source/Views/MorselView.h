//
//  MorselView.h
//  Morsel
//
//  Created by Javier Otero on 12/13/13.
//  Copyright (c) 2013 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MRSLPost;

@interface MorselView : UIView

@property (nonatomic, strong) MRSLPost *post;

- (void)reset;

@end
