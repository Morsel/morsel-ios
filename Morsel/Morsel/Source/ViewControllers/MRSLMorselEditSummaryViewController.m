//
//  MRSLMorselEditSummaryViewController.m
//  Morsel
//
//  Created by Javier Otero on 12/1/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLMorselEditSummaryViewController.h"

#import "MRSLAPIService+Morsel.h"

#import "MRSLPlaceholderTextView.h"
#import "MRSLMorselPublishShareViewController.h"

#import "MRSLMorsel.h"

@interface MRSLMorselEditSummaryViewController ()
<UITextViewDelegate>

@property (nonatomic) BOOL isPerformingRequest;

@property (weak, nonatomic) IBOutlet UILabel *summaryPlaceholderLabel;
@property (weak, nonatomic) IBOutlet UILabel *optionalLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *optionalLabelBottomConstraint;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextBarButtonItem;

@property (weak, nonatomic) IBOutlet MRSLPlaceholderTextView *summaryTextView;

@end

@implementation MRSLMorselEditSummaryViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.mp_eventView = @"morsel_summary";

    if (_morselID) {
        MRSLMorsel *morsel = [self getOrLoadMorselIfExists];
        self.summaryTextView.text = morsel.summary ?: @"";
        [self textViewDidChange:_summaryTextView];
    }

    self.title = @"Morsel summary";
    self.optionalLabel.text = @"Optional:\nAdding #hashtags can help other users discover your morsels.";
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.summaryTextView becomeFirstResponder];
    [self.optionalLabel setPreferredMaxLayoutWidth:[self.view getWidth] - (MRSLDefaultPadding * 2)];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:MRSLStoryboardSeguePublishShareMorselKey]) {
        MRSLMorsel *morsel = [self getOrLoadMorselIfExists];
        if (morsel) {
            MRSLMorselPublishShareViewController *publishShareVC = [segue destinationViewController];
            publishShareVC.morsel = morsel;
        }
    }
}

#pragma mark - Getter Methods

- (MRSLMorsel *)getOrLoadMorselIfExists {
    if (_morselID) return [MRSLMorsel MR_findFirstByAttribute:MRSLMorselAttributes.morselID
                                                    withValue:_morselID];
    return nil;
}

#pragma mark - Action Methods

- (IBAction)next {
    if (_isPerformingRequest) return;
    [[MRSLEventManager sharedManager] track:@"Tapped Button"
                                 properties:@{@"_title": @"Next",
                                              @"_view": self.mp_eventView}];
    MRSLMorsel *morsel = [self getOrLoadMorselIfExists];
    if (morsel) {
        [self.nextBarButtonItem setEnabled:NO];
        NSString *trimmedTitle = [self.summaryTextView.text stringWithWhitespaceTrimmed];
        if ([morsel.summary isEqualToString:trimmedTitle]) {
            [self.nextBarButtonItem setEnabled:YES];
            [self performSegueWithIdentifier:MRSLStoryboardSeguePublishShareMorselKey
                                      sender:nil];
        } else {
            self.isPerformingRequest = YES;
            morsel.summary = trimmedTitle;
            __weak __typeof(self) weakSelf = self;
            [_appDelegate.apiService updateMorsel:morsel
                                          success:^(id responseObject) {
                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                  [weakSelf.nextBarButtonItem setEnabled:YES];
                                                  weakSelf.isPerformingRequest = NO;
                                                  [weakSelf performSegueWithIdentifier:MRSLStoryboardSeguePublishShareMorselKey
                                                                                sender:nil];
                                              });
                                          } failure:^(NSError *error) {
                                              [UIAlertView showAlertViewForErrorString:@"Unable to update Morsel summary! Please try again."
                                                                              delegate:nil];
                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                  [weakSelf.nextBarButtonItem setEnabled:YES];
                                                  weakSelf.isPerformingRequest = NO;
                                              });
                                          }];
        }
    } else {
        [UIAlertView showAlertViewForErrorString:@"Unable to update Morsel summary! Please try again."
                                        delegate:nil];
    }
}

#pragma mark - UIKeyboard Notification Methods

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary* info = [notification userInfo];
    CGRect kbRect = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    kbRect = [self.view convertRect:kbRect
                           fromView:nil];
    self.optionalLabelBottomConstraint.constant = kbRect.size.height + 15.f;
    [self.view setNeedsUpdateConstraints];
    [UIView animateWithDuration:.25f
                     animations:^{
                         [self.view layoutIfNeeded];
                     }];
}

#pragma mark - UITextViewDelegate Methods

- (void)textViewDidChange:(UITextView *)textView {
    NSUInteger textLength = textView.text.length;
    _summaryPlaceholderLabel.hidden = !(textLength == 0);
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [self next];
        return NO;
    }
    return YES;
}

@end