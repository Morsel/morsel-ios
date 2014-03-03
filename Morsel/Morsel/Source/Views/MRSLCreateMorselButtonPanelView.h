//
//  CreateMorselButtonPanelView.h
//  Morsel
//
//  Created by Javier Otero on 1/29/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CreateMorselButtonPanelViewDelegate <NSObject>

@optional
- (void)createMorselButtonPanelDidSelectAddText;
- (void)createMorselButtonPanelDidSelectAddProgression;

@end

@interface MRSLCreateMorselButtonPanelView : UIView

@property (nonatomic, weak) id<CreateMorselButtonPanelViewDelegate> delegate;

@end
