//
//  MorselDetailPanelViewController.m
//  Morsel
//
//  Created by Javier Otero on 1/24/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLMorselDetailPanelViewController.h"

#import "JSONResponseSerializerWithData.h"
#import "MRSLDetailCommentsViewController.h"
#import "MRSLDetailHorizontalSwipePanelsViewController.h"
#import "MRSLStoryEditViewController.h"
#import "MRSLSwipePanGestureRecognizer.h"

#import "MRSLComment.h"
#import "MRSLMorsel.h"
#import "MRSLPost.h"
#import "MRSLUser.h"

static const CGFloat MRSLVerticalScrollViewPadding = 100.f;
static const CGFloat MRSLCommentPipeVerticalPadding = 84.f;
static const CGFloat MRSLScrollViewBottomDistanceTrigger = 40.f;
static const CGFloat MRSLCommentCellDefaultHeight = 110.f;

@interface MRSLMorselDetailPanelViewController ()
<MorselDetailCommentsViewControllerDelegate,
UIGestureRecognizerDelegate,
UIScrollViewDelegate>

@property (nonatomic) int morselID;

@property (nonatomic) NSUInteger commentCount;

@property (weak, nonatomic) IBOutlet UIButton *addCommentButton;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UIImageView *morselImageView;
@property (weak, nonatomic) IBOutlet UILabel *morselDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;
@property (weak, nonatomic) IBOutlet UIImageView *commentPipeView;

@property (strong, nonatomic) UIPanGestureRecognizer *subscribeablePanGestureRecognizer;

@property (weak, nonatomic) MRSLDetailHorizontalSwipePanelsViewController *swipePanelsViewController;

@property (strong, nonatomic) MRSLDetailCommentsViewController *morselDetailCommentsVC;

@end

@implementation MRSLMorselDetailPanelViewController

#pragma mark - Instance Methods

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(morselUpdated:)
                                                 name:MRSLUserDidUpdateMorselNotification
                                               object:nil];

    if (self.delegate) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(commentPosted:)
                                                     name:MRSLUserDidCreateCommentNotification
                                                   object:nil];
    }

    if (!_morsel.managedObjectContext) {
        self.morsel = [MRSLMorsel MR_findFirstByAttribute:MRSLMorselAttributes.morselID
                                                withValue:@(_morselID)];
        if (_morsel.managedObjectContext) {
            [self displayMorselContent];
        }
    }

    _contentScrollView.delegate = self;

    if (!_subscribeablePanGestureRecognizer) {
        [self attachPanRecognizerToContentScrollView];
    }

    [self alignAndResizeContent];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    if (_morsel) {
        [self displayMorselContent];
    }
}

- (void)addPanRecognizerSubscriber:(MRSLDetailHorizontalSwipePanelsViewController *)viewController {
    self.swipePanelsViewController = viewController;

    if (_contentScrollView) {
        [self attachPanRecognizerToContentScrollView];
    }
}

#pragma mark - Private Methods

- (void)morselUpdated:(NSNotification *)notification {
    MRSLMorsel *updatedMorsel = notification.object;

    if (updatedMorsel.morselIDValue == _morsel.morselIDValue) {
        [self displayMorselContent];
    }
}

- (void)setMorsel:(MRSLMorsel *)morsel {
    if (_morsel != morsel) {
        _morsel = morsel;

        if (_morsel) {
            self.morselID = morsel.morselIDValue;

            if(_morselDescriptionLabel) {
                [self displayMorselContent];
            }
        }
    }
}

- (void)displayMorselContent {
    if (!_morsel.morselPhotoURL && _morsel.morselDescription) {
        self.morselImageView.hidden = YES;
        [_morselDescriptionLabel setY:68.f];
    }

    if (_morsel.morselDescription) {
        _morselDescriptionLabel.text = _morsel.morselDescription;
    } else {
        _morselDescriptionLabel.text = @"No Description";
        _morselDescriptionLabel.textColor = [UIColor morselUserInterface];
    }

    if (_morsel.morselPhotoURL) {
        __weak UIImageView *weakImageView = _morselImageView;

        [_morselImageView setImageWithURLRequest:[_morsel morselPictureURLRequestForImageSizeType:MorselImageSizeTypeCropped]
                                placeholderImage:nil
                                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
             __strong UIImageView *strongImageView = weakImageView;
             strongImageView.image = image;
         } failure: ^(NSURLRequest * request, NSHTTPURLResponse * response, NSError * error) {
             __strong UIImageView *strongImageView = weakImageView;
             if (_morsel.morselPhotoCropped) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     strongImageView.image = [UIImage imageWithData:_morsel.morselPhotoCropped];
                 });
             } else {
                 DDLogError(@"Preview media image request failed and no local copy: %@", error.userInfo);
                 strongImageView.image = nil;
             }
             DDLogError(@"Unable to set Morsel Image in ScrollView: %@", error.userInfo);
         }];
    }

    if (!_morselDetailCommentsVC) {
        self.morselDetailCommentsVC = [[UIStoryboard morselDetailStoryboard] instantiateViewControllerWithIdentifier:@"sb_MorselDetailCommentsViewController"];
        _morselDetailCommentsVC.delegate = self;

        [self addChildViewController:_morselDetailCommentsVC];
        [self.contentScrollView addSubview:_morselDetailCommentsVC.view];
    }

    self.morselDetailCommentsVC.morsel = _morsel;


    if ([MRSLUser currentUserOwnsMorselWithCreatorID:_morsel.creator_idValue]) {
        self.likeButton.hidden = YES;
        self.editButton.hidden = NO;
    } else {
        [self setLikeButtonImageForMorsel:_morsel];
    }

    [self alignAndResizeContent];

    [self.contentScrollView setContentSize:CGSizeMake(self.view.frame.size.width, [_commentPipeView getY] + [_commentPipeView getHeight] + MRSLVerticalScrollViewPadding)];

    [self determineCommentButtonVisibility];
    [self updateMorselInformation];
}

- (void)attachPanRecognizerToContentScrollView {
    self.subscribeablePanGestureRecognizer = [[MRSLSwipePanGestureRecognizer alloc] initWithTarget:self
                                                                                            action:@selector(userPanned:)];
    [self.contentScrollView addGestureRecognizer:_subscribeablePanGestureRecognizer];
    _subscribeablePanGestureRecognizer.delegate = self;
}

- (void)alignAndResizeContent {
    CGSize descriptionSize = [_morsel.morselDescription sizeWithFont:_morselDescriptionLabel.font
                                                   constrainedToSize:CGSizeMake(_morselDescriptionLabel.frame.size.width, CGFLOAT_MAX)
                                                       lineBreakMode:NSLineBreakByWordWrapping];

    [_morselDescriptionLabel setHeight:descriptionSize.height];

    [self.commentPipeView setY:CGRectGetMaxY(_morselDescriptionLabel.frame) + MRSLCommentPipeVerticalPadding];

    CGFloat heightForComments = [self getHeightForAvailableComments];

    [_morselDetailCommentsVC.view setFrame:CGRectMake(0.f, CGRectGetMaxY(_commentPipeView.frame) + 5.f, 320.f, heightForComments)];

    CGSize updatedSize = CGSizeMake(self.view.frame.size.width, [_morselDetailCommentsVC.view getY] + [_morselDetailCommentsVC.view getHeight] + MRSLVerticalScrollViewPadding);

    [self.contentScrollView setContentSize:updatedSize];
}

- (CGFloat)getHeightForAvailableComments {
    __block CGFloat totalCommentHeight = 0.f;

    [[_morsel.comments allObjects] enumerateObjectsUsingBlock:^(MRSLComment *comment, NSUInteger idx, BOOL *stop) {
        CGSize bodySize = [comment.commentDescription sizeWithFont:[UIFont helveticaLightObliqueFontOfSize:12.f]
                                                 constrainedToSize:CGSizeMake(192.f, CGFLOAT_MAX)
                                                     lineBreakMode:NSLineBreakByWordWrapping];
        CGFloat cellIncrease = MRSLCommentCellDefaultHeight;

        if (bodySize.height > 14.f) {
            cellIncrease = cellIncrease + (bodySize.height - 14.f);
        }

        totalCommentHeight += cellIncrease;
    }];

    return totalCommentHeight;
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
    __weak __typeof(self)weakSelf = self;

    [_appDelegate.morselApiService getMorsel:_morsel
                                     success:^(id responseObject) {
                                         [weakSelf alignAndResizeContent];
                                         [_appDelegate.morselApiService getComments:weakSelf.morsel
                                                                            success:^(NSArray *responseArray) {
                                                                                [weakSelf updateCommentTableViewWithAmount:[responseArray count]];
                                                                            } failure:nil];
                                     } failure:nil];
}

- (void)updateCommentTableViewWithAmount:(NSUInteger)amount {
    self.commentCount = amount;

    self.morselDetailCommentsVC.morsel = _morsel;

    [self alignAndResizeContent];
}

- (void)commentPosted:(NSNotification *)notification {
    MRSLMorsel *updatedMorsel = notification.object;

    if (updatedMorsel.morselIDValue != _morsel.morselIDValue) return;

    CGRect focusedFrame = CGRectMake(1.f, self.contentScrollView.contentSize.height - 5.f, 5.f, 5.f);

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.contentScrollView scrollRectToVisible:focusedFrame
                                           animated:YES];
    });
}

#pragma mark - Action Methods

- (IBAction)addComment {
    if ([self.delegate respondsToSelector:@selector(morselDetailPanelViewDidSelectAddComment)]) {
        [self.delegate morselDetailPanelViewDidSelectAddComment];
    }
}

- (IBAction)editMorsel {
    MRSLStoryEditViewController *editStoryVC = [[UIStoryboard storyManagementStoryboard] instantiateViewControllerWithIdentifier:@"sb_MRSLStoryEditViewController"];

    editStoryVC.postID = _morsel.post.postID;

    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:editStoryVC];
    [self.navigationController presentViewController:navController
                                            animated:YES
                                          completion:nil];
}

- (IBAction)toggleLikeMorsel {
    _likeButton.enabled = NO;

    [_appDelegate.morselApiService likeMorsel:_morsel
                                  shouldLike:!_morsel.likedValue
                                     didLike:^(BOOL doesLike)
     {
         [[MRSLEventManager sharedManager] track:(doesLike) ? @"Liked Morsel" : @"Unliked Morsel"
                               properties:@{@"view": @"MorselFeedCollectionViewCell",
                                            @"morsel_id": _morsel.morselID}];

         [_morsel setLikedValue:doesLike];

         [self setLikeButtonImageForMorsel:_morsel];
     } failure: ^(NSError * error) {
         MRSLServiceErrorInfo *serviceErrorInfo = error.userInfo[JSONResponseSerializerWithServiceErrorInfoKey];

         [UIAlertView showAlertViewForServiceError:serviceErrorInfo
                                          delegate:nil];

         _likeButton.enabled = YES;
     }];
}

- (void)setLikeButtonImageForMorsel:(MRSLMorsel *)morsel {
    UIImage *likeImage = [UIImage imageNamed:morsel.likedValue ? @"icon-like-active" : @"icon-like-inactive"];

    [_likeButton setImage:likeImage
                 forState:UIControlStateNormal];

    _likeButton.enabled = YES;
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

- (void)morselDetailCommentsViewControllerDidSelectUser:(MRSLUser *)user {
    if ([self.delegate respondsToSelector:@selector(morselDetailPanelViewDidSelectUser:)]) {
        [self.delegate morselDetailPanelViewDidSelectUser:user];
    }
}

#pragma mark - Destruction

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    _contentScrollView.delegate = nil;

    if (_subscribeablePanGestureRecognizer) {
        [_contentScrollView removeGestureRecognizer:_subscribeablePanGestureRecognizer];
        self.subscribeablePanGestureRecognizer = nil;
    }
}

@end
