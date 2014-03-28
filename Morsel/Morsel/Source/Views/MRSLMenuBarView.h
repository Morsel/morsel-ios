//
//  MRSLTabBarView.h
//  Morsel
//
//  Created by Javier Otero on 3/3/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MRSLMenuBarButton.h"

@protocol MRSLMenuBarViewDelegate <NSObject>

@optional
- (void)menuBarDidSelectButtonOfType:(MRSLMenuBarButtonType)buttonType;

@end

@interface MRSLMenuBarView : UIView

@property (weak, nonatomic) IBOutlet id <MRSLMenuBarViewDelegate> delegate;

- (void)reset;

@end
