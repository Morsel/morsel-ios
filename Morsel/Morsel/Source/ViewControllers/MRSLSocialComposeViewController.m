//
//  MRSLSocialComposeViewController.m
//  Morsel
//
//  Created by Javier Otero on 5/14/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLSocialComposeViewController.h"

#import "MRSLSocialServiceTwitter.h"

#import "GCPlaceholderTextView.h"

#import "MRSLMorsel.h"
#import "MRSLUser.h"

@interface MRSLSocialComposeViewController ()
<UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneBarButtonItem;

@property (weak, nonatomic) IBOutlet UILabel *textCountLabel;

@property (weak, nonatomic) IBOutlet GCPlaceholderTextView *textView;

@end

@implementation MRSLSocialComposeViewController

#pragma mark - Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    self.textView.placeholder = [NSString stringWithFormat:@"Let your friends know why %@ is awesome!", _morsel.title];
    self.textView.text = [NSString stringWithFormat:@"“%@” from %@ on Morsel %@", _morsel.title, [_morsel.creator fullNameOrTwitterHandle], _morsel.twitter_mrsl ?: _morsel.url];
    [self textViewDidChange:_textView];
   // [NSURL URLWithString:_morsel.morselPhotoURL];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.textView becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [self.view endEditing:YES];
}

#pragma mark - Action Methods

- (IBAction)dismiss {
    if (_cancelBlock) _cancelBlock();
    [super dismiss];
}

- (IBAction)done:(id)sender {
    if ([self.textView.text length] > 0) {
        __weak __typeof(self) weakSelf = self;
        [[MRSLSocialServiceTwitter sharedService] postStatus:self.textView.text
                                                     success:^(BOOL success) {
                                                         [weakSelf.presentingViewController dismissViewControllerAnimated:YES
                                                                                                               completion:nil];
                                                         if (weakSelf.successBlock) weakSelf.successBlock(YES);
                                                     } failure:^(NSError *error) {
                                                         [UIAlertView showAlertViewForErrorString:[NSString stringWithFormat:@"Error sending tweet: %@", error]
                                                                                         delegate:nil];
                                                     }];
    } else {
        [UIAlertView showAlertViewForErrorString:@"Please add text in order to post!"
                                        delegate:nil];
    }
}

#pragma mark - UITextViewDelegate Methods

- (void)textViewDidChange:(UITextView *)textView {
    NSUInteger textLength = textView.text.length;
    _doneBarButtonItem.enabled = !(textLength == 0);
    if (textLength < 130) {
        [_textCountLabel setTextColor:[UIColor morselGreen]];
    } else if (textLength >= 130 && textLength <= 140) {
        [_textCountLabel setTextColor:[UIColor morselRed]];
    }
    NSUInteger remainingTextLength = 140 - textLength;
    _textCountLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)remainingTextLength];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSUInteger textLength = (textView.text.length - range.length) + text.length;
    if ([text isEqualToString:@"\n"]) {
        [self done:nil];
        return NO;
    } else if (textLength > 140) {
        return NO;
    }
    return YES;
}

@end
