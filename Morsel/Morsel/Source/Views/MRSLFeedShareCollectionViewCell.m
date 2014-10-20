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
<UITextViewDelegate>

@property (weak, nonatomic) IBOutlet MRSLProfileImageView *profileImageView;

@property (weak, nonatomic) IBOutlet UITextView *userInfoTextView;
@property (weak, nonatomic) IBOutlet UITextView *nextInfoTextView;
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;
@property (weak, nonatomic) IBOutlet UIButton *nextMorselButton;
@property (weak, nonatomic) IBOutlet UIButton *reportButton;

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

    NSString *fullName = [_morsel.creator fullName];
    NSMutableAttributedString *infoAttributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ \n%@", fullName, _morsel.creator.bio]
                                                                                             attributes:@{NSFontAttributeName : [UIFont preferredRobotoFontForTextStyle:UIFontTextStyleBody]}];
    [infoAttributedString addAttribute:NSLinkAttributeName
                                 value:@"profile://display"
                                 range:[[infoAttributedString string] rangeOfString:fullName]];
    [infoAttributedString addAttribute:NSFontAttributeName
                                 value:[UIFont preferredRobotoFontForTextStyle:UIFontTextStyleHeadline]
                                 range:[[infoAttributedString string] rangeOfString:fullName]];
    self.userInfoTextView.attributedText = infoAttributedString;

    NSString *nextMorsel = @"View next morsel";
#warning Get next morsel name
    NSString *morselName = @"";
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

    _reportButton.hidden = [_morsel.creator isCurrentUser];
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

- (IBAction)displayProfile {
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
