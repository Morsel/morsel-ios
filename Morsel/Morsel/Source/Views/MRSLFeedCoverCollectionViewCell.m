//
//  MRSLFeedCoverCollectionViewCell.m
//  Morsel
//
//  Created by Javier Otero on 3/24/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLFeedCoverCollectionViewCell.h"

#import "MRSLAPIService+Morsel.h"
#import "NSDate+TimeAgoMinimized.h"

#import "MRSLItemImageView.h"
#import "MRSLPlaceViewController.h"
#import "MRSLProfileImageView.h"
#import "MRSLProfileViewController.h"
#import "MRSLMorselTaggedUsersViewController.h"

#import "MRSLItem.h"
#import "MRSLMorsel.h"
#import "MRSLPlace.h"
#import "MRSLUser.h"

@interface MRSLFeedCoverCollectionViewCell ()
<UITextViewDelegate>

@property (nonatomic) int morselID;
@property (strong, nonatomic) NSAttributedString *taggedAttributedString;

@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UILabel *timeAgoLabel;
@property (weak, nonatomic) IBOutlet UILabel *morselTitleLabel;

@property (weak, nonatomic) IBOutlet UIButton *likeCountButton;
@property (weak, nonatomic) IBOutlet UIButton *featuredButton;
@property (weak, nonatomic) IBOutlet UITextView *infoTextView;

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
        [self.timeAgoLabel addStandardShadow];
        [self.likeCountButton addStandardShadow];
    });
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    self.contentView.frame = bounds;
}

- (void)setMorsel:(MRSLMorsel *)morsel {
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
    dispatch_async(dispatch_get_main_queue(), ^{
        self.featuredButton.hidden = !([self isHomeFeedItem] && _morsel.feedItemFeaturedValue);
        self.morselTitleLabel.text = _morsel.title;
        self.profileImageView.user = _morsel.creator;
        self.timeAgoLabel.text = [_morsel.publishedDate timeAgoMinimized];
        [self.likeCountButton setTitle:[NSString stringWithFormat:@"%@ likes", _morsel.like_count]
                              forState:UIControlStateNormal];

        NSString *fullName = [_morsel.creator fullName];
        NSMutableAttributedString *infoAttributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"by %@", fullName]
                                                                                                 attributes:@{NSFontAttributeName : [UIFont robotoSlabRegularFontOfSize:10.f]}];
        [infoAttributedString addAttribute:NSLinkAttributeName
                                     value:@"profile://display"
                                     range:[[infoAttributedString string] rangeOfString:fullName]];
        [infoAttributedString addAttribute:NSFontAttributeName
                                     value:[UIFont robotoSlabBoldFontOfSize:18.f]
                                     range:[[infoAttributedString string] rangeOfString:fullName]];

        self.editButton.hidden = ![_morsel.creator isCurrentUser];

        if (_morsel.place) {
            NSString *placeName = _morsel.place.name;
            NSMutableAttributedString *placeAttributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@ %@, %@", placeName, _morsel.place.city, _morsel.place.state]
                                                                                                      attributes:@{NSFontAttributeName : [UIFont preferredRobotoFontForTextStyle:UIFontTextStyleCaption1]}];
            [placeAttributedString addAttribute:NSLinkAttributeName
                                          value:@"place://display"
                                          range:[[placeAttributedString string] rangeOfString:placeName]];
            [placeAttributedString addAttribute:NSFontAttributeName
                                          value:[UIFont preferredRobotoFontForTextStyle:UIFontTextStyleSubheadline]
                                          range:[[placeAttributedString string] rangeOfString:placeName]];
            [infoAttributedString appendAttributedString:placeAttributedString];
        }

        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setAlignment:NSTextAlignmentCenter];
        [infoAttributedString addAttribute:NSParagraphStyleAttributeName
                                     value:paragraphStyle
                                     range:NSMakeRange(0, infoAttributedString.length)];

        self.infoTextView.attributedText = infoAttributedString;

        if (self.morsel.morselIDValue == self.morselID && self.taggedAttributedString) {

            [infoAttributedString appendAttributedString:self.taggedAttributedString];

            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            [paragraphStyle setAlignment:NSTextAlignmentCenter];
            [infoAttributedString addAttribute:NSParagraphStyleAttributeName
                                         value:paragraphStyle
                                         range:NSMakeRange(0, infoAttributedString.length)];
            self.infoTextView.attributedText = infoAttributedString;
        }

        if (_morsel.has_tagged_usersValue && self.morsel.morselIDValue != self.morselID) {
#warning Improve line leading between tagged users and rest of content
            self.morselID = self.morsel.morselIDValue;
            __weak __typeof(self) weakSelf = self;
            [_appDelegate.apiService getTaggedUsersForMorsel:self.morsel
                                                   withMaxID:nil
                                                   orSinceID:nil
                                                    andCount:nil
                                                     success:^(NSArray *responseArray) {
                                                         if (weakSelf) {
                                                             NSMutableAttributedString *taggedAttributedString = [[NSMutableAttributedString alloc] initWithString:@"\nwith "
                                                                                                                                                        attributes:@{NSFontAttributeName : [UIFont preferredRobotoFontForTextStyle:UIFontTextStyleCaption1]}];
                                                             int userEnumCount = 0;
                                                             for (id objectID in responseArray) {
                                                                 MRSLUser *taggedUser = [MRSLUser MR_findFirstByAttribute:MRSLUserAttributes.userID
                                                                                                                withValue:objectID
                                                                                                                inContext:[NSManagedObjectContext MR_defaultContext]];
                                                                 NSString *userFullName = taggedUser.fullName;
                                                                 NSMutableAttributedString *taggedUserAttributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", userFullName]];
                                                                 [taggedUserAttributedString addAttribute:NSLinkAttributeName
                                                                                                    value:[NSString stringWithFormat:@"user://%i", taggedUser.userIDValue]
                                                                                                    range:[[taggedUserAttributedString string] rangeOfString:userFullName]];
                                                                 [taggedUserAttributedString addAttribute:NSFontAttributeName
                                                                                                    value:[UIFont preferredRobotoFontForTextStyle:UIFontTextStyleSubheadline]
                                                                                                    range:[[taggedUserAttributedString string] rangeOfString:userFullName]];

                                                                 BOOL hasMore = ([responseArray count] - (userEnumCount + 1) > 0);
                                                                 if (hasMore) {
                                                                     NSAttributedString *commaAttributedString = [[NSMutableAttributedString alloc] initWithString:@", "
                                                                                                                                                        attributes:@{NSFontAttributeName : [UIFont preferredRobotoFontForTextStyle:UIFontTextStyleCaption1]}];

                                                                     [taggedUserAttributedString appendAttributedString:commaAttributedString];
                                                                 }

                                                                 [taggedAttributedString appendAttributedString:taggedUserAttributedString];
                                                                 userEnumCount++;
                                                                 if (userEnumCount == 2) {
                                                                     if (hasMore) {
                                                                         NSString *moreString = [NSString stringWithFormat:@"%i more", [responseArray count] - userEnumCount];
                                                                         NSMutableAttributedString *moreAttributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"and %@", moreString]
                                                                                                                                                                  attributes:@{NSFontAttributeName : [UIFont preferredRobotoFontForTextStyle:UIFontTextStyleCaption1]}];
                                                                         [moreAttributedString addAttribute:NSLinkAttributeName
                                                                                                      value:@"more://display"
                                                                                                      range:[[moreAttributedString string] rangeOfString:moreString]];
                                                                         [moreAttributedString addAttribute:NSFontAttributeName
                                                                                                      value:[UIFont preferredRobotoFontForTextStyle:UIFontTextStyleSubheadline]
                                                                                                      range:[[moreAttributedString string] rangeOfString:moreString]];
                                                                         [taggedAttributedString appendAttributedString:moreAttributedString];
                                                                     }
                                                                     break;
                                                                 }
                                                             }

                                                             [infoAttributedString appendAttributedString:taggedAttributedString];

                                                             weakSelf.taggedAttributedString = taggedAttributedString;

                                                             NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
                                                             [paragraphStyle setAlignment:NSTextAlignmentCenter];
                                                             [infoAttributedString addAttribute:NSParagraphStyleAttributeName
                                                                                          value:paragraphStyle
                                                                                          range:NSMakeRange(0, infoAttributedString.length)];

                                                             weakSelf.infoTextView.attributedText = infoAttributedString;
                                                         }
                                                     } failure:^(NSError *error) {

                                                     }];
        }

        if (!_morsel.publishedDate) {
            self.timeAgoLabel.hidden = YES;
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
    } else if ([[URL scheme] isEqualToString:@"user"]) {
        NSNumber *userID = @([[URL host] intValue]);
        [self displayProfileWithID:userID];
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
