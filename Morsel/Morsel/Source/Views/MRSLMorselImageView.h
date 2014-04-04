//
//  MRSLMorselImageView.h
//  Morsel
//
//  Created by Javier Otero on 3/13/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MRSLMorselImageViewDelegate <NSObject>

@optional
- (void)morselImageViewDidSelectMorsel:(MRSLMorsel *)morsel;

@end

@interface MRSLMorselImageView : UIImageView

@property (weak, nonatomic) id <MRSLMorselImageViewDelegate> delegate;

@property (weak, nonatomic) MRSLMorsel *morsel;

- (void)displayEmptyStoryState;

@end
