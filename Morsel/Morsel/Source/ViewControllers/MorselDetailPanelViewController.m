//
//  MorselDetailPanelViewController.m
//  Morsel
//
//  Created by Javier Otero on 1/24/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MorselDetailPanelViewController.h"

#import "JSONResponseSerializerWithData.h"
#import "ModelController.h"
#import "MorselDetailCommentsViewController.h"
#import "MRSLDetailHorizontalSwipePanelsViewController.h"
#import "MRSLSwipePanGestureRecognizer.h"

#import "MRSLMorsel.h"

static const CGFloat MRSLVerticalScrollViewPadding = 100.f;
static const CGFloat MRSLCommentPipeVerticalPadding = 84.f;
static const CGFloat MRSLScrollViewBottomDistanceTrigger = 40.f;
static const CGFloat MRSLCommentCellDefaultHeight = 110.f;

@interface MorselDetailPanelViewController ()
    <MorselDetailCommentsViewControllerDelegate,
     UIGestureRecognizerDelegate,
     UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *addCommentButton;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIImageView *morselImageView;
@property (weak, nonatomic) IBOutlet UILabel *morselDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;
@property (weak, nonatomic) IBOutlet UIImageView *commentPipeView;

@property (nonatomic, strong) UIPanGestureRecognizer *subscribeablePanGestureRecognizer;

@property (nonatomic, weak) MRSLDetailHorizontalSwipePanelsViewController *swipePanelsViewController;

@property (nonatomic, strong) MorselDetailCommentsViewController *morselDetailCommentsVC;

@end

@implementation MorselDetailPanelViewController

#pragma mark - Instance Methods

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _contentScrollView.delegate = self;
    
    if (!_subscribeablePanGestureRecognizer) {
        [self attachPanRecognizerToContentScrollView];
    }
}

- (void)addPanRecognizerSubscriber:(MRSLDetailHorizontalSwipePanelsViewController *)viewController {
    self.swipePanelsViewController = viewController;
    
    if (_contentScrollView) {
        [self attachPanRecognizerToContentScrollView];
    }
}

- (void)attachPanRecognizerToContentScrollView {
    self.subscribeablePanGestureRecognizer = [[MRSLSwipePanGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(userPanned:)];
    [self.contentScrollView addGestureRecognizer:_subscribeablePanGestureRecognizer];
    _subscribeablePanGestureRecognizer.delegate = self;
}

#pragma mark - Private Methods

- (void)setMorsel:(MRSLMorsel *)morsel {
    if (_morsel != morsel) {
        _morsel = morsel;
        
        if ([_morsel.morselDescription length] > 0) {
            // Text Version
        }
        
        if (_morsel.morselDescription) {
            CGSize descriptionSize = [_morsel.morselDescription sizeWithFont:_morselDescriptionLabel.font
                                                           constrainedToSize:CGSizeMake(_morselDescriptionLabel.frame.size.width, CGFLOAT_MAX)
                                                               lineBreakMode:NSLineBreakByWordWrapping];
            
            [_morselDescriptionLabel setHeight:descriptionSize.height];
            
            _morselDescriptionLabel.text = _morsel.morselDescription;
        } else {
            _morselDescriptionLabel.text = @"No Description";
            _morselDescriptionLabel.textColor = [UIColor morselUserInterface];
        }
        
        [self.commentPipeView setY:CGRectGetMaxY(_morselDescriptionLabel.frame) + MRSLCommentPipeVerticalPadding];
        
        [self.contentScrollView setContentSize:CGSizeMake(self.view.frame.size.width, [_commentPipeView getY] + [_commentPipeView getHeight] + MRSLVerticalScrollViewPadding)];
        
        self.morselDetailCommentsVC = [[UIStoryboard morselDetailStoryboard] instantiateViewControllerWithIdentifier:@"MorselDetailCommentsViewController"];
        _morselDetailCommentsVC.morsel = _morsel;
        _morselDetailCommentsVC.delegate = self;
        
        [_morselDetailCommentsVC.view setFrame:CGRectMake(0.f, [_commentPipeView getY] + [_commentPipeView getHeight] + 5.f, 320.f, 0.f)];
        
        [self addChildViewController:_morselDetailCommentsVC];
        [self.contentScrollView addSubview:_morselDetailCommentsVC.view];
        
        if (_morsel.morselPictureURL) {
            __weak UIImageView *weakImageView = _morselImageView;
            
            [_morselImageView setImageWithURLRequest:[_morsel morselPictureURLRequestForImageSizeType:MorselImageSizeTypeCropped]
                                    placeholderImage:nil
                                             success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
             {
                 if (image) {
                     __strong UIImageView *strongImageView = weakImageView;
                     strongImageView.image = image;
                 }
             } failure: ^(NSURLRequest * request, NSHTTPURLResponse * response, NSError * error) {
                 DDLogError(@"Unable to set Morsel Image in ScrollView: %@", error.userInfo);
             }];
        }
        
        if (_morsel.belongsToCurrentUser) {
            self.likeButton.hidden = YES;
        } else {
            [self setLikeButtonImageForMorsel:_morsel];
        }
        
        [self determineCommentButtonVisibility];
        [self updateMorselInformation];
    }
}

- (IBAction)addComment {
    if ([self.delegate respondsToSelector:@selector(morselDetailPanelViewDidSelectAddComment)]) {
        [self.delegate morselDetailPanelViewDidSelectAddComment];
    }
}

- (IBAction)toggleLikeMorsel {
    _likeButton.enabled = NO;

    [[ModelController sharedController].morselApiService likeMorsel:_morsel
                                                         shouldLike:!_morsel.likedValue
                                                            didLike:^(BOOL doesLike)
    {
        [_morsel setLikedValue:doesLike];

        [self setLikeButtonImageForMorsel:_morsel];
    } failure: ^(NSError * error) {
        NSDictionary *errorDictionary = error.userInfo[JSONResponseSerializerWithDataKey];
        NSString *errorString = [NSString stringWithFormat:@"Like Error: %@", errorDictionary[@"errors"]];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:errorString
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];

        _likeButton.enabled = YES;
    }];
}

- (void)setLikeButtonImageForMorsel:(MRSLMorsel *)morsel {
    UIImage *likeImage = [UIImage imageNamed:morsel.likedValue ? @"icon-like-active" : @"icon-like-inactive"];

    [_likeButton setImage:likeImage
                 forState:UIControlStateNormal];

    _likeButton.enabled = YES;
}

- (void)determineCommentButtonVisibility {
    CGFloat scrollViewHeight = _contentScrollView.frame.size.height;
    CGFloat scrollContentSizeHeight = _contentScrollView.contentSize.height;
    CGFloat scrollOffset = _contentScrollView.contentOffset.y;
    
    if ([self.delegate respondsToSelector:@selector(morselDetailPanelViewScrollOffsetChanged:)]) {
        [self.delegate morselDetailPanelViewScrollOffsetChanged:scrollOffset];
    }
    
    if (scrollOffset + scrollViewHeight >= scrollContentSizeHeight - MRSLScrollViewBottomDistanceTrigger) {
        // Near end
        [UIView animateWithDuration:.2f animations:^{
            [_addCommentButton setY:scrollViewHeight -  [_addCommentButton getHeight]];
        }];
    } else {
        // Anywhere else
        [UIView animateWithDuration:.2f animations:^{
            [_addCommentButton setY:scrollViewHeight];
        }];
    }
}

- (void)updateMorselInformation {
    [[ModelController sharedController].morselApiService getComments:_morsel
                                                             success:^(NSArray *responseArray) {
        [self updateCommentTableViewWithAmount:[responseArray count]];
    } failure:nil];
}

- (void)updateCommentTableViewWithAmount:(NSUInteger)amount {
    [self.morselDetailCommentsVC.view setHeight:MRSLCommentCellDefaultHeight * amount];
    self.morselDetailCommentsVC.morsel = _morsel;
    
    CGSize updatedSize = CGSizeMake(self.view.frame.size.width, [_morselDetailCommentsVC.view getY] + [_morselDetailCommentsVC.view getHeight] + MRSLVerticalScrollViewPadding);
    CGRect focusedFrame = CGRectMake(0.f, updatedSize.height, 1.f, 1.f);
    
    [self.contentScrollView setContentSize:updatedSize];
    [self.contentScrollView scrollRectToVisible:focusedFrame
                                       animated:YES];
}

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidScroll: (UIScrollView*)scrollView {
    [self determineCommentButtonVisibility];
}

#pragma mark - UIGestureRecognizerDelegate Methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)userPanned:(UIPanGestureRecognizer *)panRecognizer {
    if (self.swipePanelsViewController) {
        [self.swipePanelsViewController userPanned:panRecognizer];
    }
}

#pragma mark - MorselDetailCommentsViewControllerDelegate

- (void)morselDetailCommentsViewControllerDidUpdateWithAmountOfComments:(NSUInteger)amount {
    [self updateCommentTableViewWithAmount:amount];
}

#pragma mark - Destruction

- (void)dealloc {
    _contentScrollView.delegate = nil;
    if (_subscribeablePanGestureRecognizer) {
        [_contentScrollView removeGestureRecognizer:_subscribeablePanGestureRecognizer];
        self.subscribeablePanGestureRecognizer = nil;
    }
}

@end
