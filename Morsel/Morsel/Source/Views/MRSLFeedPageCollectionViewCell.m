//
//  MRSLFeedPageCollectionViewCell.m
//  Morsel
//
//  Created by Javier Otero on 3/24/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLFeedPageCollectionViewCell.h"

#import <NSDate+TimeAgo/NSDate+TimeAgo.h>

#import "MRSLAPIService+Like.h"

#import "MRSLModalCommentsViewController.h"
#import "MRSLProfileViewController.h"

#import "MRSLItemImageView.h"
#import "MRSLProfileImageView.h"

#import "MRSLItem.h"
#import "MRSLMorsel.h"
#import "MRSLUser.h"

@interface MRSLFeedPageCollectionViewCell ()
<UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *commentButton;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;

@property (weak, nonatomic) IBOutlet MRSLItemImageView *itemImageView;

@end

@implementation MRSLFeedPageCollectionViewCell

#pragma mark - Instance Methods

- (void)awakeFromNib {
    [super awakeFromNib];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateContent:)
                                                 name:NSManagedObjectContextObjectsDidChangeNotification
                                               object:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_item) [self populateContent];
        __weak __typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (weakSelf) {
                [weakSelf.itemImageView removeBorder];
                [weakSelf.itemImageView addDefaultBorderForDirections:MRSLBorderSouth];
            }
        });
    });
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    self.contentView.frame = bounds;
}

- (void)setItem:(MRSLItem *)item {
    _item = item;
    [self populateContent];
}

- (void)populateContent {
    dispatch_async(dispatch_get_main_queue(), ^{
        _itemImageView.item = _item;

        self.descriptionTextView.text = self.item.itemDescription;
        self.descriptionTextView.font = [UIFont preferredRobotoFontForTextStyle:UIFontTextStyleBody];

        [_commentButton setTitle:[NSString stringWithFormat:@"%@", (_item.comment_countValue == 0) ? @"Add comment" : [NSString stringWithFormat:@"%@ comment%@", _item.comment_count, (_item.comment_countValue > 1) ? @"s" : @""]]
                             forState:UIControlStateNormal];

        if (![_item.morsel publishedDate]) {
            self.commentButton.enabled = NO;
        }
    });
}

#pragma mark - Action Methods

- (IBAction)displayComments {
    UINavigationController *commentNC = [[UIStoryboard feedStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardCommentsKey];
    MRSLModalCommentsViewController *modalCommentsVC = [[commentNC viewControllers] firstObject];
    modalCommentsVC.item = self.item;
    [[NSNotificationCenter defaultCenter] postNotificationName:MRSLAppShouldDisplayBaseViewControllerNotification
                                                        object:commentNC];
}

#pragma mark - UITextView Delegate

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    if ([[URL scheme] rangeOfString:@"http"].location != NSNotFound) {
        [[NSNotificationCenter defaultCenter] postNotificationName:MRSLAppShouldDisplayWebBrowserNotification object:@{@"title": @"Web browser",
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
        if ([managedObject isKindOfClass:[MRSLItem class]]) {
            MRSLItem *item = (MRSLItem *)managedObject;
            if (item.itemIDValue == weakSelf.item.itemIDValue) {
                [weakSelf populateContent];
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
