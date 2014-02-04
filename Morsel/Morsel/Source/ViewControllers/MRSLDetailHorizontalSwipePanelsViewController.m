//
//  MRSLDetailHorizontalSwipePanelsViewController.m
//  Morsel
//
//  Created by Javier Otero on 2/3/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLDetailHorizontalSwipePanelsViewController.h"

#import "MorselDetailPanelViewController.h"
#import "MRSLDetailHorizontalSwipePanelView.h"

static const CGFloat MRSLVelocityThresholdForPageChange = 800.f;

@interface MRSLDetailHorizontalSwipePanelsViewController ()
    <UIGestureRecognizerDelegate>

@property (nonatomic) BOOL isFirstPage;
@property (nonatomic) BOOL isLastPage;

@property (nonatomic) CGFloat pageWidth;
@property (nonatomic) CGFloat panelLeftInitialX;
@property (nonatomic) CGFloat panelCenterInitialX;
@property (nonatomic) CGFloat panelRightInitialX;
@property (nonatomic) CGPoint initialPoint;
@property (nonatomic) CGFloat swipingContainerInitialX;
@property (nonatomic) NSUInteger currentPage;
@property (nonatomic) NSUInteger totalPages;

@property (nonatomic) ScrollViewDirection direction;

@property (nonatomic, weak) MRSLDetailHorizontalSwipePanelView *panelViewLeft;
@property (nonatomic, weak) MRSLDetailHorizontalSwipePanelView *panelViewCenter;
@property (nonatomic, weak) MRSLDetailHorizontalSwipePanelView *panelViewRight;

@property (nonatomic, strong) UIView *swipingContainerView;
@property (nonatomic, strong) NSMutableArray *swipePanelViews;
@property (nonatomic, strong) NSMutableArray *visibleViewControllers;

@end

@implementation MRSLDetailHorizontalSwipePanelsViewController

#pragma mark - Instance Methods

- (void)addSwipeCollectionViewControllers:(NSArray *)viewControllers
                      withinContainerView:(UIView *)viewOrNil {
    self.swipingContainerView = viewOrNil ?: self.view;
    self.visibleViewControllers = [NSMutableArray array];
    
    CGRect containingFrame = [self frameForParentSwipingView:_swipingContainerView];
    
    MRSLDetailHorizontalSwipePanelView *panelViewA = [[MRSLDetailHorizontalSwipePanelView alloc] initWithFrame:containingFrame];
    MRSLDetailHorizontalSwipePanelView *panelViewB = [[MRSLDetailHorizontalSwipePanelView alloc] initWithFrame:containingFrame];
    MRSLDetailHorizontalSwipePanelView *panelViewC = [[MRSLDetailHorizontalSwipePanelView alloc] initWithFrame:containingFrame];
    
    self.panelLeftInitialX = -containingFrame.size.width;
    self.panelCenterInitialX = 0.f;
    self.panelRightInitialX = containingFrame.size.width;
    
    [panelViewA setX:_panelLeftInitialX];
    [panelViewB setX:_panelCenterInitialX];
    [panelViewC setX:_panelRightInitialX];
    
    [_swipingContainerView addSubview:panelViewA];
    [_swipingContainerView addSubview:panelViewB];
    [_swipingContainerView addSubview:panelViewC];
    
    self.panelViewLeft = panelViewA;
    self.panelViewCenter = panelViewB;
    self.panelViewRight = panelViewC;
    
    self.swipePanelViews = [NSMutableArray arrayWithObjects:panelViewA, panelViewB, panelViewC, nil];
    
    self.swipeViewControllers = viewControllers;
    self.totalPages = [self.swipeViewControllers count];
    
    [self.swipeViewControllers enumerateObjectsUsingBlock:^(UIViewController *viewController, NSUInteger idx, BOOL *stop) {
        if ([viewController isKindOfClass:[MorselDetailPanelViewController class]]) {
            [(MorselDetailPanelViewController *)viewController addPanRecognizerSubscriber:self];
        }
        [viewController.view setFrame:containingFrame];
    }];
}

/*
 Layout swipe panels goes through the current array of swipeViewControllers and, depending on the range or page, displays them in a specific order. There are always three visible views (that contain subviews of three focused view controllers). 
 
 If there are not three available, which is usually when the user reaches the first or last page, [NSNull] is used as a placeholder.
 
 The MRSLDetailHorizontalSwipePanelView stores whether it is a placeholder to allow the pan recognizer easier access for deciding what type of view is contained.
 */
- (void)layoutSwipePanels {
    self.isFirstPage = (self.currentPage == 0);
    self.isLastPage = (self.currentPage == [self.swipeViewControllers count] - 1);
    
    NSUInteger pageIndex = self.currentPage;
    
    for (UIViewController *viewController in _visibleViewControllers) {
        [viewController removeFromParentViewController];
        [viewController.view removeFromSuperview];
    }
    
    NSMutableArray *currentViewControllers = [NSMutableArray array];
    
    if (_isFirstPage) {
        [currentViewControllers addObject:[NSNull null]];
    } else {
        pageIndex -= 1;
    }
    
    for (int i = pageIndex; i < [self.swipeViewControllers count] ; i++) {
        UIViewController *swipeVC = [self.swipeViewControllers objectAtIndex:i];
        [currentViewControllers addObject:swipeVC];
        // If the amount of current view controllers is or exceeds 3, stop immediately. Only 3 items are necessary.
        // If this is the last page, only two are necessary to fill the current view controllers array.
        if ([currentViewControllers count] >= 3 || (_isLastPage && [currentViewControllers count] == 2)) break;
    }
    
    if (_isLastPage) {
        [currentViewControllers addObject:[NSNull null]];
    }
    
    [currentViewControllers enumerateObjectsUsingBlock:^(UIViewController *viewController, NSUInteger idx, BOOL *stop) {
        MRSLDetailHorizontalSwipePanelView *viewForVC = [_swipePanelViews objectAtIndex:idx];
        viewForVC.clipsToBounds = YES;
        viewForVC.userInteractionEnabled = YES;
        
        if (![viewController isKindOfClass:[NSNull class]]) {
            viewForVC.isPlaceholder = NO;
            
            [self addChildViewController:viewController];
            [viewForVC addSubview:viewController.view];
            
            [_visibleViewControllers addObject:viewController];
        } else {
            viewForVC.isPlaceholder = YES;
        }
    }];
}

- (CGRect)frameForParentSwipingView:(UIView *)parentView {
    return CGRectMake(0.f, 0.f, parentView.frame.size.width, parentView.frame.size.height);
}

#pragma mark - Private Methods

- (void)displayPanelForPage:(NSUInteger)page
                   animated:(BOOL)animated {
    // For now, animated functionality is considered to be polish. Value still being passed for when implementation is complete.
    
    self.currentPage = page;
    
    [self layoutSwipePanels];
    
    if ([self respondsToSelector:@selector(didUpdateCurrentPage:)]) {
        [self didUpdateCurrentPage:self.currentPage];
    }
}

- (void)didUpdateCurrentPage:(NSUInteger)page {
    // Override
}

#pragma mark - UIGestureRecognizerDelegate Methods

- (void)userPanned:(UIPanGestureRecognizer *)panRecognizer {
    CGPoint translationPoint = [panRecognizer translationInView:self.view];
    CGPoint velocityPoint = [panRecognizer velocityInView:self.view];
    CGFloat centerPanelPercentOpen = _panelViewCenter.frame.origin.x / self.view.frame.size.width;
    
    if (panRecognizer.state == UIGestureRecognizerStateEnded) {
        if ((centerPanelPercentOpen < 0.f || velocityPoint.x < -MRSLVelocityThresholdForPageChange)&&
            !_panelViewRight.isPlaceholder) {
            self.previousExists = YES;
            // Swiping left makes right new center. Increment current page.
            MRSLDetailHorizontalSwipePanelView *removedPanel = [_swipePanelViews firstObject];
            
            [_swipePanelViews removeObject:removedPanel];
            [_swipePanelViews addObject:removedPanel];

            self.previousPage = self.currentPage;
            
            self.currentPage++;
            
            [self.panelViewLeft setX:_panelRightInitialX];
            
            [UIView animateWithDuration:.2f animations:^{
                [self.panelViewCenter setX:_panelLeftInitialX];
                [self.panelViewRight setX:_panelCenterInitialX];
            } completion:^(BOOL finished) {
                self.panelViewLeft = [_swipePanelViews objectAtIndex:0];
                self.panelViewCenter = [_swipePanelViews objectAtIndex:1];
                self.panelViewRight = [_swipePanelViews objectAtIndex:2];
                
                [self displayPanelForPage:self.currentPage
                                 animated:NO];
            }];
            
        } else if ((centerPanelPercentOpen > 0.5f  || velocityPoint.x > MRSLVelocityThresholdForPageChange) &&
                   !_panelViewLeft.isPlaceholder) {
            self.previousExists = YES;
            // Swiping right makes left new center. Decrement current page.
            MRSLDetailHorizontalSwipePanelView *removedPanel = [_swipePanelViews lastObject];
            
            [_swipePanelViews removeObject:removedPanel];
            [_swipePanelViews insertObject:removedPanel
                                   atIndex:0];
            
            self.previousPage = self.currentPage;
            
            self.currentPage--;
            
            [self.panelViewRight setX:_panelLeftInitialX];
            
            [UIView animateWithDuration:.2f animations:^{
                [self.panelViewLeft setX:_panelCenterInitialX];
                [self.panelViewCenter setX:_panelRightInitialX];
            } completion:^(BOOL finished) {
                self.panelViewLeft = [_swipePanelViews objectAtIndex:0];
                self.panelViewCenter = [_swipePanelViews objectAtIndex:1];
                self.panelViewRight = [_swipePanelViews objectAtIndex:2];
                
                [self displayPanelForPage:self.currentPage
                                 animated:NO];
            }];
        } else {
            self.previousExists = NO;
            [UIView animateWithDuration:.2f animations:^{
                [self.panelViewLeft setX:_panelLeftInitialX];
                [self.panelViewCenter setX:_panelCenterInitialX];
                [self.panelViewRight setX:_panelRightInitialX];
            }];
        }
    }
    
    // Only allow recognizer processing to continue if it is horizontal
    if (fabs(translationPoint.y) > fabs(translationPoint.x)) return;
    
    CGPoint currentPoint = [panRecognizer locationInView:self.view];
    
    if (panRecognizer.state == UIGestureRecognizerStateBegan) {
        self.initialPoint = currentPoint;
        self.swipingContainerInitialX = _swipingContainerView.frame.origin.x;
        self.direction = ScrollViewDirectionNone;
    } else if (panRecognizer.state == UIGestureRecognizerStateChanged) {
        if (_direction == ScrollViewDirectionNone) {
            CGFloat differenceX = currentPoint.x - self.initialPoint.x;
            CGFloat differenceY = currentPoint.y - self.initialPoint.y;
            
            if (differenceX < 0) differenceX *= -1;
            if (differenceY < 0) differenceY *= -1;
            
            if (differenceX > 10.f ||
                differenceY > 10.f) {
                if (differenceX > differenceY) {
                    self.direction = ScrollViewDirectionHorizontal;
                }
                else {
                    self.direction = ScrollViewDirectionVertical;
                }
            }
        }
        
        if (_direction == ScrollViewDirectionHorizontal) {
            // This is where resistance will be added when user attempting to scroll towards a Null container
            
            [self.panelViewLeft setX:_panelLeftInitialX + translationPoint.x];
            [self.panelViewCenter setX:_panelCenterInitialX + translationPoint.x];
            [self.panelViewRight setX:_panelRightInitialX + translationPoint.x];
        }
    }
}

@end
