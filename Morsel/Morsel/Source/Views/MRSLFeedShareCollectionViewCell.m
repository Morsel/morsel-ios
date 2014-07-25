//
//  MRSLFeedShareCollectionViewCell.m
//  Morsel
//
//  Created by Javier Otero on 4/4/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLFeedShareCollectionViewCell.h"

#import "MRSLProfileViewController.h"

#import "MRSLItemImageView.h"
#import "MRSLProfileImageView.h"
#import "MRSLSocialService.h"

#import "MRSLItem.h"
#import "MRSLMorsel.h"
#import "MRSLUser.h"

@interface MRSLFeedShareCollectionViewCell ()

@property (weak, nonatomic) IBOutlet MRSLItemImageView *shareCoverImageView;
@property (weak, nonatomic) IBOutlet MRSLProfileImageView *profileImageView;

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userBioLabel;
@property (weak, nonatomic) IBOutlet UILabel *morselTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;
@property (weak, nonatomic) IBOutlet UIButton *nextMorselButton;
@property (weak, nonatomic) IBOutlet UIButton *previousMorselButton;

@end

@implementation MRSLFeedShareCollectionViewCell

#pragma mark - Instance Methods

- (void)awakeFromNib {
    [super awakeFromNib];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateContent:)
                                                 name:NSManagedObjectContextObjectsDidChangeNotification
                                               object:nil];
    [self.morselTitleLabel addStandardShadow];
}

- (void)setMorsel:(MRSLMorsel *)morsel {
    if (_morsel != morsel) {
        _morsel = morsel;
        [self populateContent];
    }
}

#pragma mark - Private Methods

- (void)populateContent {
    _shareCoverImageView.item = [_morsel coverItem];
    _morselTitleLabel.text = _morsel.title;
    _profileImageView.user = _morsel.creator;
    _userNameLabel.text = _morsel.creator.fullName;
    _userBioLabel.text = _morsel.creator.bio;

    [_userBioLabel sizeToFit];
    [_userBioLabel setWidth:192.f];
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

#pragma mark - Action Methods

- (IBAction)displayProfile {
    UINavigationController *profileNC = [[UIStoryboard profileStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardProfileKey];
    MRSLProfileViewController *profileVC = [[profileNC viewControllers] firstObject];
    profileVC.user = _morsel.creator;
    [[NSNotificationCenter defaultCenter] postNotificationName:MRSLAppShouldDisplayBaseViewControllerNotification
                                                        object:profileNC];
}

- (IBAction)displayPreviousMorsel:(id)sender {
    [[MRSLEventManager sharedManager] track:@"Tapped Prev Morsel"
                                 properties:@{@"view": @"main_feed",
                                              @"morsel_id": NSNullIfNil(_morsel.morselID)}];
    if ([self.delegate respondsToSelector:@selector(feedShareCollectionViewCellDidSelectPreviousMorsel)]) {
        [self.delegate feedShareCollectionViewCellDidSelectPreviousMorsel];
    }
}

- (IBAction)displayNextMorsel:(id)sender {
    [[MRSLEventManager sharedManager] track:@"Tapped Next Morsel"
                                 properties:@{@"view": @"main_feed",
                                              @"morsel_id": NSNullIfNil(_morsel.morselID)}];
    if ([self.delegate respondsToSelector:@selector(feedShareCollectionViewCellDidSelectNextMorsel)]) {
        [self.delegate feedShareCollectionViewCellDidSelectNextMorsel];
    }
}

- (IBAction)shareToFacebook {
    if ([self.delegate respondsToSelector:@selector(feedShareCollectionViewCellDidSelectShareFacebook)]) {
        [self.delegate feedShareCollectionViewCellDidSelectShareFacebook];
    }
}

- (IBAction)shareToTwitter {
    if ([self.delegate respondsToSelector:@selector(feedShareCollectionViewCellDidSelectShareTwitter)]) {
        [self.delegate feedShareCollectionViewCellDidSelectShareTwitter];
    }
}

#pragma mark - Dealloc

- (void)dealloc {
    self.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
