//
//  MRSLFeedCoverCollectionViewCell.m
//  Morsel
//
//  Created by Javier Otero on 3/24/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLFeedCoverCollectionViewCell.h"

#import "MRSLAPIService+Morsel.h"

#import "MRSLItemImageView.h"
#import "MRSLPlaceViewController.h"
#import "MRSLProfileImageView.h"
#import "MRSLProfileViewController.h"
#import "MRSLMorselTaggedUsersViewController.h"
#import "MRSLMorselSearchResultsViewController.h"
#import "MRSLStandardTextView.h"

#import "MRSLItem.h"
#import "MRSLMorsel.h"
#import "MRSLPlace.h"
#import "MRSLUser.h"

@interface MRSLFeedCoverCollectionViewCell ()
<UITextViewDelegate>

@property (nonatomic) int morselID;
@property (strong, nonatomic) NSAttributedString *coverAttributedString;
@property (strong, nonatomic) MRSLStandardTextView *infoTextView;

@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UILabel *morselTitleLabel;
@property (weak, nonatomic) IBOutlet UIView *infoBackgroundView;
@property (weak, nonatomic) IBOutlet UIButton *likeCountButton;
@property (weak, nonatomic) IBOutlet UIButton *featuredButton;

@property (weak, nonatomic) IBOutlet MRSLProfileImageView *profileImageView;

@end

@implementation MRSLFeedCoverCollectionViewCell

#pragma mark - Instance Methods

- (void)awakeFromNib {
    [super awakeFromNib];

    self.morselID = -1;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateContent:)
                                                 name:NSManagedObjectContextObjectsDidChangeNotification
                                               object:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.morselTitleLabel addStandardShadow];
        [self.editButton addStandardShadow];
    });
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    self.contentView.frame = bounds;
}

- (void)setMorsel:(MRSLMorsel *)morsel {
    if (morsel.morselIDValue != self.morsel.morselIDValue) self.coverAttributedString = nil;
    _morsel = morsel;
    [self populateContent];
}

#pragma mark - Action Methods

- (void)displayProfileWithID:(NSNumber *)userID {
    MRSLUser *user = [MRSLUser MR_findFirstByAttribute:MRSLUserAttributes.userID
                                             withValue:userID];
    if (user) {
        UINavigationController *profileNC = [[UIStoryboard profileStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardProfileKey];
        MRSLProfileViewController *profileVC = [[profileNC viewControllers] firstObject];
        profileVC.user = user;
        [[NSNotificationCenter defaultCenter] postNotificationName:MRSLAppShouldDisplayBaseViewControllerNotification
                                                            object:profileNC];
    }
}

- (void)displayPlace {
    if (!_morsel.place) return;
    UINavigationController *placeNC = [[UIStoryboard placesStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardPlaceKey];
    MRSLPlaceViewController *placeVC = [[placeNC viewControllers] firstObject];
    placeVC.place = _morsel.place;
    [[NSNotificationCenter defaultCenter] postNotificationName:MRSLAppShouldDisplayBaseViewControllerNotification
                                                        object:placeNC];
}

#pragma mark - Private Methods

- (void)populateContent {
    if (!self.infoTextView) {

        MRSLStandardTextView *infoTextView = [MRSLStandardTextView textViewWithHashtagHighlightingFromAttributedString:nil
                                                                                                                 frame:CGRectMake(20.f, self.frame.size.height - 20.f, self.frame.size.width - 40.f, 20.f)
                                                                                                              delegate:self];
        [infoTextView setTranslatesAutoresizingMaskIntoConstraints:NO];
        infoTextView.editable = NO;
        infoTextView.selectable = YES;
        infoTextView.scrollEnabled = NO;
        infoTextView.showsVerticalScrollIndicator = NO;

        [self addSubview:infoTextView];

        NSDictionary *metrics = @{@"padding": @20,
                                  @"smallpadding": @5,
                                  @"bottom": @0};
        UIView *profileImageView = self.profileImageView;
        NSDictionary *views = NSDictionaryOfVariableBindings(infoTextView, profileImageView);
        @try {
            NSArray *hConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|-(==padding)-[infoTextView]-(==padding)-|"
                                                                            options:0
                                                                            metrics:metrics
                                                                              views:views];
            NSArray *vConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[profileImageView]-(==smallpadding)-[infoTextView(>=50.0)]-(==bottom)-|"
                                                                            options:0
                                                                            metrics:metrics
                                                                              views:views];
            [self addConstraints:hConstraints];
            [self addConstraints:vConstraints];
            [infoTextView setContentCompressionResistancePriority:UILayoutPriorityRequired
                                                          forAxis:UILayoutConstraintAxisVertical];
            [infoTextView setContentHuggingPriority:UILayoutPriorityRequired
                                            forAxis:UILayoutConstraintAxisVertical];
        } @catch (NSException *exception) {
            DDLogError(@"Constraints error: %@", exception);
        }

        self.infoTextView = infoTextView;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.featuredButton.hidden = !([self isHomeFeedItem] && _morsel.feedItemFeaturedValue);
        self.morselTitleLabel.text = _morsel.title;
        self.profileImageView.user = _morsel.creator;
        [self.likeCountButton setTitle:[NSString stringWithFormat:@"%@ like%@", _morsel.like_count, (_morsel.like_countValue > 1) ? @"s" : @""]
                              forState:UIControlStateNormal];
        self.likeCountButton.hidden = (_morsel.like_countValue == 0);
        self.editButton.hidden = ![_morsel.creator isCurrentUser];



        if (self.morsel.morselIDValue == self.morselID && self.coverAttributedString) {
            self.infoTextView.attributedText = self.coverAttributedString;
        } else {
            self.morselID = self.morsel.morselIDValue;
            __weak __typeof(self) weakSelf = self;
            self.infoTextView.attributedText = nil;
            [self.morsel getCoverInformation:^(NSAttributedString *attributedString, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.infoTextView.attributedText = attributedString;
                    weakSelf.coverAttributedString = attributedString;
                });
            }];
        }

        if (!_morsel.publishedDate) {
            self.profileImageView.userInteractionEnabled = NO;
            self.editButton.hidden = YES;
        }
    });
}

#pragma mark - UITextView Delegate

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    if ([[URL scheme] isEqualToString:@"profile"]) {
        [self displayProfileWithID:_morsel.creator.userID];
        return NO;
    } else if ([[URL scheme] isEqualToString:@"place"]) {
        [self displayPlace];
        return NO;
    } else if ([[URL scheme] isEqualToString:@"more"]) {
        UINavigationController *taggedNC = [[UIStoryboard feedStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardTaggedUsersKey];
        MRSLMorselTaggedUsersViewController *taggedUsersVC = [[taggedNC viewControllers] firstObject];
        taggedUsersVC.morsel = self.morsel;
        [[NSNotificationCenter defaultCenter] postNotificationName:MRSLAppShouldDisplayBaseViewControllerNotification
                                                            object:taggedNC];
        return NO;
    } else if ([[URL scheme] isEqualToString:@"user"]) {
        NSNumber *userID = @([[URL host] intValue]);
        [self displayProfileWithID:userID];
    } else if ([[URL scheme] isEqualToString:@"hashtag"]) {
        UINavigationController *searchResultsNC = [[UIStoryboard exploreStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardMorselSearchKey];
        MRSLMorselSearchResultsViewController *morselSearchResultsVC = [[searchResultsNC viewControllers] firstObject];
        morselSearchResultsVC.hashtagString = [URL host];
        [[NSNotificationCenter defaultCenter] postNotificationName:MRSLAppShouldDisplayBaseViewControllerNotification
                                                            object:searchResultsNC];
        return NO;
    } else if ([[URL scheme] rangeOfString:@"http"].location != NSNotFound) {
        [[NSNotificationCenter defaultCenter] postNotificationName:MRSLAppShouldDisplayWebBrowserNotification object:@{@"title": @"Loading...",
                                                                                                                       @"url": URL}];
        return NO;
    }
    return YES;
}

#pragma mark - Notification Methods

- (void)updateContent:(NSNotification *)notification {
    NSDictionary *userInfoDictionary = [notification userInfo];
    NSSet *updatedObjects = [userInfoDictionary objectForKey:NSUpdatedObjectsKey];

    __weak __typeof(self) weakSelf = self;
    [updatedObjects enumerateObjectsUsingBlock:^(NSManagedObject *managedObject, BOOL *stop) {
        if ([managedObject isKindOfClass:[MRSLMorsel class]]) {
            MRSLMorsel *morsel = (MRSLMorsel *)managedObject;
            if (morsel.morselIDValue == weakSelf.morsel.morselIDValue) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf populateContent];
                });
                *stop = YES;
            }
        }
    }];
}

#pragma mark - Dealloc

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
