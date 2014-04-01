//
//  MRSLFeedPageCollectionViewCell.m
//  Morsel
//
//  Created by Javier Otero on 3/24/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLFeedPageCollectionViewCell.h"

#import "JSONResponseSerializerWithData.h"
#import "MRSLMorselImageView.h"
#import "MRSLProfileImageView.h"

#import "MRSLMorsel.h"
#import "MRSLPost.h"
#import "MRSLUser.h"

static const CGFloat MRSLDescriptionHeightLimit = 60.f;

@interface MRSLFeedPageCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UILabel *likeCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *morselDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *viewMoreButton;
@property (weak, nonatomic) IBOutlet UIImageView *gradientView;

@property (weak, nonatomic) IBOutlet MRSLMorselImageView *morselImageView;

@end

@implementation MRSLFeedPageCollectionViewCell

#pragma mark - Instance Methods

- (void)awakeFromNib {
    [super awakeFromNib];
    [_morselDescriptionLabel addStandardShadow];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideContent)
                                                 name:MRSLModalWillDisplayNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showContent)
                                                 name:MRSLModalWillDismissNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateContent:)
                                                 name:NSManagedObjectContextObjectsDidChangeNotification
                                               object:nil];
}

- (void)setMorsel:(MRSLMorsel *)morsel {
    _morsel = morsel;
    _morselImageView.morsel = _morsel;
    [self populateContent];
}

- (void)populateContent {
    _morselDescriptionLabel.text = _morsel.morselDescription;

    _gradientView.hidden = ([_morsel.morselDescription length] == 0);

    [_morselDescriptionLabel sizeToFit];
    [_morselDescriptionLabel setWidth:280.f];

    CGSize textSize = [_morsel.morselDescription sizeWithFont:_morselDescriptionLabel.font
                                            constrainedToSize:CGSizeMake([_morselDescriptionLabel getWidth], CGFLOAT_MAX)
                                                lineBreakMode:NSLineBreakByWordWrapping];

    if (textSize.height > MRSLDescriptionHeightLimit) {
        [_morselDescriptionLabel setHeight:MRSLDescriptionHeightLimit];
        [_viewMoreButton setHidden:NO];
    } else {
        [_morselDescriptionLabel setHeight:textSize.height];
        [_viewMoreButton setHidden:YES];
    }

    [_morselDescriptionLabel setY:[_morselImageView getY] + [_morselImageView getHeight] - ([_morselDescriptionLabel getHeight] + ((textSize.height > MRSLDescriptionHeightLimit) ? 30.f : 5.f))];

    _editButton.hidden = ![_morsel.post.creator isCurrentUser];
    _likeCountLabel.text = [NSString stringWithFormat:@"%i", _morsel.like_countValue];
    _commentCountLabel.text = [NSString stringWithFormat:@"%i", _morsel.comment_countValue];

    [self setLikeButtonImageForMorsel:_morsel];

    [_likeCountLabel sizeToFit];
    [_commentCountLabel sizeToFit];
}

#pragma mark - Notification Methods

- (void)hideContent {
    [self toggleContent:NO];
}

- (void)showContent {
    [self toggleContent:YES];
}

- (void)updateContent:(NSNotification *)notification {
    NSDictionary *userInfoDictionary = [notification userInfo];
    NSSet *updatedObjects = [userInfoDictionary objectForKey:NSUpdatedObjectsKey];

    __weak __typeof(self) weakSelf = self;
    [updatedObjects enumerateObjectsUsingBlock:^(NSManagedObject *managedObject, BOOL *stop) {
        if ([managedObject isKindOfClass:[MRSLMorsel class]]) {
            MRSLMorsel *morsel = (MRSLMorsel *)managedObject;
            if (morsel.morselIDValue == weakSelf.morsel.morselIDValue) {
                [weakSelf populateContent];
                *stop = YES;
            }
        }
    }];
}

#pragma mark - Private Methods

- (void)toggleContent:(BOOL)shouldDisplay {
    [UIView animateWithDuration:.2f
                     animations:^{
                         [_morselDescriptionLabel setAlpha:shouldDisplay];
                         [_viewMoreButton setAlpha:shouldDisplay];
    }];
}

#pragma mark - Action Methods

- (IBAction)toggleLike {
    _likeButton.enabled = NO;
    
    [[MRSLEventManager sharedManager] track:@"Tapped Like Icon"
                                 properties:@{@"view": @"Feed",
                                              @"morsel_id": _morsel.morselID}];

    [_morsel setLikedValue:!_morsel.likedValue];
    [self setLikeButtonImageForMorsel:_morsel];

    [_appDelegate.morselApiService likeMorsel:_morsel
                                   shouldLike:_morsel.likedValue
                                      didLike:nil
                                      failure: ^(NSError * error) {
                                          MRSLServiceErrorInfo *serviceErrorInfo = error.userInfo[JSONResponseSerializerWithServiceErrorInfoKey];

                                          [UIAlertView showAlertViewForServiceError:serviceErrorInfo
                                                                           delegate:nil];

                                          _likeButton.enabled = YES;
                                          [_morsel setLikedValue:!_morsel.likedValue];
                                      }];
}

- (void)setLikeButtonImageForMorsel:(MRSLMorsel *)morsel {
    UIImage *likeImage = [UIImage imageNamed:morsel.likedValue ? @"icon-like-active" : @"icon-like-inactive"];
    
    [_likeButton setImage:likeImage
                 forState:UIControlStateNormal];
    
    _likeButton.enabled = YES;
}

#pragma mark - Dealloc

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
