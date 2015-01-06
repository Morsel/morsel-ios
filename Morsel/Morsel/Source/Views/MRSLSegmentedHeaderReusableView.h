//
//  MRSLSegmentedHeaderReusableView.h
//  Morsel
//
//  Created by Javier Otero on 5/23/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MRSLSegmentedHeaderReusableViewDelegate <NSObject>

@optional
- (void)segmentedHeaderDidSelectIndex:(NSInteger)index;
- (NSIndexSet *)segmentedButtonViewIndexSetToDisplay;

@end

@interface MRSLSegmentedHeaderReusableView : UICollectionReusableView

@property (weak, nonatomic) id <MRSLSegmentedHeaderReusableViewDelegate> delegate;

@end
