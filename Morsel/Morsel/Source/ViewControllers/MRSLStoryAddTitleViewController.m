//
//  MRSLStoryTitleViewController.m
//  Morsel
//
//  Created by Javier Otero on 3/3/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLStoryAddTitleViewController.h"

#import <GCPlaceholderTextView/GCPlaceholderTextView.h>

#import "MRSLStoryEditViewController.h"

#import "MRSLPost.h"

@interface MRSLStoryAddTitleViewController ()
<UITextViewDelegate>

@property (weak, nonatomic) IBOutlet GCPlaceholderTextView *storyTitleTextView;

@property (weak, nonatomic) IBOutlet UILabel *titleCountLimitLabel;
@property (weak, nonatomic) IBOutlet UILabel *titlePlaceholderLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneBarButtonItem;

@property (weak, nonatomic) MRSLPost *post;

@end

@implementation MRSLStoryAddTitleViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self getOrLoadPostIfExists];

    if (_post) {
        self.storyTitleTextView.text = self.post.title;
        [self textViewDidChange:_storyTitleTextView];
    }

    self.storyTitleTextView.placeholder = @"What are you working on?";
    [self.storyTitleTextView becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [self.view endEditing:YES];
}

#pragma mark - Getter Methods

- (MRSLPost *)getOrLoadPostIfExists {
    if (_postID) self.post = [MRSLPost MR_findFirstByAttribute:MRSLPostAttributes.postID
                                                     withValue:_postID];
    return _post;
}

#pragma mark - Action Methods

- (IBAction)done:(id)sender {
    [[MRSLEventManager sharedManager] track:@"Tapped Done"
                                 properties:@{@"view": @"Add Story Title"}];
    if (_isUserEditingTitle) {
        self.post = [self getOrLoadPostIfExists];
        if (![self.post.title isEqualToString:self.storyTitleTextView.text]) {
            self.post.title = self.storyTitleTextView.text;
            [_appDelegate.morselApiService updatePost:_post
                                              success:nil
                                              failure:nil];
        }
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        self.post = [MRSLPost MR_createEntity];
        _post.draft = @YES;
        _post.title = self.storyTitleTextView.text;

        [_appDelegate.morselApiService createPost:_post
                                          success:^(id responseObject) {
            MRSLStoryEditViewController *editStoryVC = [[UIStoryboard storyManagementStoryboard] instantiateViewControllerWithIdentifier:@"sb_MRSLStoryEditViewController"];
            editStoryVC.shouldPresentMediaCapture = YES;
            editStoryVC.postID = _post.postID;
            [self.navigationController pushViewController:editStoryVC
                                                 animated:YES];
        } failure:^(NSError *error) {
            [UIAlertView showAlertViewForErrorString:@"Unable to create Post! Please try again."
                                            delegate:nil];
        }];
    }
}

#pragma mark - UITextViewDelegate Methods

- (void)textViewDidChange:(UITextView *)textView {
    NSUInteger textLength = textView.text.length;
    _doneBarButtonItem.enabled = !(textLength == 0);
    _titlePlaceholderLabel.hidden = !(textLength == 0);
    if (textLength < 40) {
        [_titleCountLimitLabel setTextColor:[UIColor morselGreen]];
    } else if (textLength >= 40 && textLength <= 50) {
        [_titleCountLimitLabel setTextColor:[UIColor morselRed]];
    }
    NSUInteger remainingTextLength = 50 - textLength;
    _titleCountLimitLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)remainingTextLength];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSUInteger textLength = (textView.text.length - range.length) + text.length;
    if ([text isEqualToString:@"\n"]) {
        [self done:nil];
        return NO;
    } else if (textLength > 50) {
        return NO;
    }
    return YES;
}

@end
