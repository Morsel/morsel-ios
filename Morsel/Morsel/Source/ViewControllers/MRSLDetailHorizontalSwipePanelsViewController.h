//
//  MRSLDetailHorizontalSwipePanelsViewController.h
//  Morsel
//
//  Created by Javier Otero on 2/3/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ScrollViewDirection)
{
    ScrollViewDirectionNone,
    ScrollViewDirectionVertical,
    ScrollViewDirectionHorizontal
};

@class MorselDetailPanelViewController;

@interface MRSLDetailHorizontalSwipePanelsViewController : UIViewController

@property (readwrite) BOOL previousExists;

@property (readwrite) NSUInteger previousPage;

@property (nonatomic, strong) NSArray *swipeViewControllers;

- (void)addSwipeCollectionViewControllers:(NSArray *)viewControllers
                      withinContainerView:(UIView *)viewOrNil;
- (void)displayPanelForPage:(NSUInteger)page
                   animated:(BOOL)animated;
- (void)userPanned:(UIPanGestureRecognizer *)panRecognizer;


- (void)didUpdateCurrentPage:(NSUInteger)page;

@end
