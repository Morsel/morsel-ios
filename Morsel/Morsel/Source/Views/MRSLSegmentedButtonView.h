//
//  MRSLSegmentedButtonView.h
//  Morsel
//
//  Created by Javier Otero on 5/20/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MRSLSegmentedButtonViewDelegate <NSObject>

@optional
- (void)segmentedButtonViewDidSelectIndex:(NSInteger)index;

@end

@interface MRSLSegmentedButtonView : UIView

@property (nonatomic) BOOL shouldDisplayProfessionalTabs;

@property (weak, nonatomic) IBOutlet id <MRSLSegmentedButtonViewDelegate> delegate;

@property (nonatomic) NSInteger selectedIndex;

@end
