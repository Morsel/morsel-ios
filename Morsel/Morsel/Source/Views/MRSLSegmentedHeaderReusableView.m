//
//  MRSLSegmentedHeaderReusableView.m
//  Morsel
//
//  Created by Javier Otero on 5/23/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLSegmentedHeaderReusableView.h"

#import "MRSLSegmentedButtonView.h"

@interface MRSLSegmentedHeaderReusableView ()
<MRSLSegmentedButtonViewDelegate>

@property (weak, nonatomic) IBOutlet MRSLSegmentedButtonView *buttonView;

@end

@implementation MRSLSegmentedHeaderReusableView

#pragma mark - MRSLSegmentedButtonViewDelegate

- (void)segmentedButtonViewDidSelectIndex:(NSInteger)index {
    if ([self.delegate respondsToSelector:@selector(segmentedHeaderDidSelectIndex:)]) {
        [self.delegate segmentedHeaderDidSelectIndex:index];
    }
}

- (NSIndexSet *)segmentedButtonViewIndexSetToDisplay {
    if ([self.delegate respondsToSelector:@selector(segmentedButtonViewIndexSetToDisplay)]) {
        return [self.delegate segmentedButtonViewIndexSetToDisplay];
    }
    return nil;
}

@end
