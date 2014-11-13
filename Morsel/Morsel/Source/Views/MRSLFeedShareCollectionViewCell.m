//
//  MRSLFeedShareCollectionViewCell.m
//  Morsel
//
//  Created by Javier Otero on 4/4/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLFeedShareCollectionViewCell.h"

#import "MRSLAPIService+Profile.h"

#import "MRSLProfileViewController.h"

#import "MRSLItemImageView.h"
#import "MRSLProfileImageView.h"
#import "MRSLSocialService.h"

#import "MRSLFollowButton.h"
#import "MRSLItem.h"
#import "MRSLMorsel.h"
#import "MRSLUser.h"

@interface MRSLFeedShareCollectionViewCell ()
<UITextViewDelegate>

@property (nonatomic) int morselID;

@property (weak, nonatomic) IBOutlet MRSLProfileImageView *profileImageView;
@property (weak, nonatomic) IBOutlet MRSLFollowButton *followButton;

@property (weak, nonatomic) IBOutlet UITextView *userInfoTextView;
@property (weak, nonatomic) IBOutlet UITextView *nextInfoTextView;
@property (weak, nonatomic) IBOutlet UIButton *nextMorselButton;
@property (weak, nonatomic) IBOutlet UIButton *reportButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *profileImageDescriptionSpacing;

@end

@implementation MRSLFeedShareCollectionViewCell

#pragma mark - Instance Methods

- (void)awakeFromNib {
    [super awakeFromNib];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateContent:)
                                                 name:NSManagedObjectContextObjectsDidChangeNotification
                                               object:nil];
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    self.contentView.frame = bounds;
}

- (void)setMorsel:(MRSLMorsel *)morsel {
    if (_morsel != morsel) {
        _morsel = morsel;
        [self populateContent];
    }
}

#pragma mark - Private Methods

- (void)populateContent {
    _profileImageView.user = _morsel.creator;

    _reportButton.hidden = [_morsel.creator isCurrentUser];
    _followButton.hidden = YES;
    _nextMorselButton.hidden = (!self.nextMorsel);
    _nextInfoTextView.hidden = (!self.nextMorsel);

    self.profileImageDescriptionSpacing.constant = self.followButton.hidden ? 0.f : 40.f;
    [self setNeedsUpdateConstraints];

    if (!_reportButton.hidden) {
        self.morselID = self.morsel.morselIDValue;
        __weak __typeof(self)weakSelf = self;
        [_appDelegate.apiService getUserProfile:_morsel.creator
                                        success:^(id responseObject) {
                                            if (weakSelf && weakSelf.morselID == weakSelf.morsel.morselIDValue &&
                                                !weakSelf.morsel.creator.followingValue) {
                                                weakSelf.followButton.user = weakSelf.morsel.creator;

                                                weakSelf.profileImageDescriptionSpacing.constant = weakSelf.followButton.hidden ? 0.f : 40.f;
                                                [weakSelf setNeedsUpdateConstraints];
                                            }
                                        } failure:nil];
    }

    self.userInfoTextView.attributedText = [_morsel.creator profileInformation];

    if (!_nextInfoTextView.hidden) {
        NSString *nextMorsel = @"View next morsel";
        NSString *morselName = self.nextMorsel.title ?: @"";
        NSMutableAttributedString *nextInfoAttributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n%@", nextMorsel, morselName]];
        [nextInfoAttributedString addAttribute:NSLinkAttributeName
                                         value:@"next://display"
                                         range:[[nextInfoAttributedString string] rangeOfString:nextMorsel]];
        [nextInfoAttributedString addAttribute:NSFontAttributeName
                                         value:[UIFont preferredRobotoFontForTextStyle:UIFontTextStyleSubheadline]
                                         range:[[nextInfoAttributedString string] rangeOfString:nextMorsel]];
        [nextInfoAttributedString addAttribute:NSLinkAttributeName
                                         value:@"next://display"
                                         range:[[nextInfoAttributedString string] rangeOfString:morselName]];
        [nextInfoAttributedString addAttribute:NSFontAttributeName
                                         value:[UIFont preferredRobotoFontForTextStyle:UIFontTextStyleCaption1]
                                         range:[[nextInfoAttributedString string] rangeOfString:morselName]];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setAlignment:NSTextAlignmentRight];
        [nextInfoAttributedString addAttribute:NSParagraphStyleAttributeName
                                         value:paragraphStyle
                                         range:NSMakeRange(0, nextInfoAttributedString.length)];
        self.nextInfoTextView.attributedText = nextInfoAttributedString;
    }
}

#pragma mark - UITextView Delegate

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    if ([[URL scheme] isEqualToString:@"profile"]) {
        [self displayProfile];
        return NO;
    } else if ([[URL scheme] isEqualToString:@"next"]) {
        [self displayNextMorsel:nil];
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

#pragma mark - Action Methods

- (void)displayProfile {
    UINavigationController *profileNC = [[UIStoryboard profileStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardProfileKey];
    MRSLProfileViewController *profileVC = [[profileNC viewControllers] firstObject];
    profileVC.user = _morsel.creator;
    [[NSNotificationCenter defaultCenter] postNotificationName:MRSLAppShouldDisplayBaseViewControllerNotification
                                                        object:profileNC];
}

- (IBAction)displayNextMorsel:(id)sender {
    [[MRSLEventManager sharedManager] track:@"Tapped Button"
                                 properties:@{@"_title": @"Next Morsel",
                                              @"_view": @"feed",
                                              @"morsel_id": NSNullIfNil(_morsel.morselID)}];
    if ([self.delegate respondsToSelector:@selector(feedShareCollectionViewCellDidSelectNextMorsel)]) {
        [self.delegate feedShareCollectionViewCellDidSelectNextMorsel];
    }
}

#pragma mark - Dealloc

- (void)dealloc {
    self.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
