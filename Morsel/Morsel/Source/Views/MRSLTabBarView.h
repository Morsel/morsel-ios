//
//  MRSLTabBarView.h
//  Morsel
//
//  Created by Javier Otero on 3/3/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MRSLTabBarButton.h"

@protocol MRSLTabBarViewDelegate <NSObject>

@optional
- (void)tabBarDidSelectButtonOfType:(MRSLTabBarButtonType)buttonType;

@end

@interface MRSLTabBarView : UIView

@property (nonatomic, weak) IBOutlet id <MRSLTabBarViewDelegate> delegate;

- (void)reset;

@end
