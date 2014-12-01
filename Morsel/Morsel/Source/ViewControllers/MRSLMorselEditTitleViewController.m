//
//  MRSLMorselTitleViewController.m
//  Morsel
//
//  Created by Javier Otero on 3/3/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLMorselEditTitleViewController.h"

#import <GCPlaceholderTextView/GCPlaceholderTextView.h>

#import "MRSLAPIService+Morsel.h"

#import "MRSLMorselEditViewController.h"

#import "MRSLMorsel.h"

@interface MRSLMorselEditTitleViewController ()
<UIAlertViewDelegate,
UITextViewDelegate>

@property (nonatomic) BOOL isPerformingRequest;

@property (weak, nonatomic) IBOutlet GCPlaceholderTextView *morselTitleTextView;

@property (weak, nonatomic) IBOutlet UILabel *titleCountLimitLabel;
@property (weak, nonatomic) IBOutlet UILabel *titlePlaceholderLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneBarButtonItem;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *countLimitConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textBottomConstraint;

@property (strong, nonatomic) NSString *previousTitle;

@end

@implementation MRSLMorselEditTitleViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.mp_eventView = @"morsel_title";

    if (_morselID) {
        MRSLMorsel *morsel = [self getOrLoadMorselIfExists];
        self.morselTitleTextView.text = ([morsel hasPlaceholderTitle]) ? @"" : morsel.title;
        self.previousTitle = ([morsel hasPlaceholderTitle]) ? @"" : morsel.title;
        [self textViewDidChange:_morselTitleTextView];
    }

    [self.doneBarButtonItem setEnabled:NO];

    self.title = @"Morsel title";
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.morselTitleTextView becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

#pragma mark - Getter Methods

- (MRSLMorsel *)getOrLoadMorselIfExists {
    if (_morselID) return [MRSLMorsel MR_findFirstByAttribute:MRSLMorselAttributes.morselID
                                                    withValue:_morselID];
    return nil;
}

#pragma mark - Action Methods

- (void)goBack {
    if ([self isDirty]) {
        [UIAlertView showAlertViewWithTitle:@"Warning"
                                    message:@"You have unsaved changes, are you sure you want to discard them?"
                                   delegate:self
                          cancelButtonTitle:@"Cancel"
                          otherButtonTitles:@"Discard", nil];
    } else {
        [super goBack];
    }
}

- (IBAction)done:(id)sender {
    if (_isPerformingRequest || ![self isDirty]) return;
    [[MRSLEventManager sharedManager] track:@"Tapped Button"
                                 properties:@{@"_title": @"Done",
                                              @"_view": self.mp_eventView}];
    MRSLMorsel *morsel = [self getOrLoadMorselIfExists];
    if (morsel) {
        NSString *trimmedTitle = [self.morselTitleTextView.text stringWithWhitespaceTrimmed];
        if ([morsel.title isEqualToString:trimmedTitle]) {
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            self.isPerformingRequest = YES;
            morsel.title = trimmedTitle;
            __weak __typeof(self) weakSelf = self;
            [_appDelegate.apiService updateMorsel:morsel
                                          success:^(id responseObject) {
                                              [weakSelf.navigationController popViewControllerAnimated:YES];
                                              weakSelf.isPerformingRequest = NO;
                                          } failure:^(NSError *error) {
                                              morsel.title = weakSelf.previousTitle;
                                              [UIAlertView showAlertViewForErrorString:@"Unable to update Morsel title! Please try again."
                                                                              delegate:nil];
                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                  [weakSelf.doneBarButtonItem setEnabled:YES];
                                                  weakSelf.isPerformingRequest = NO;
                                              });
                                          }];
        }
    } else {
        [UIAlertView showAlertViewForErrorString:@"Unable to update Morsel title! Please try again."
                                        delegate:nil];
    }
}

#pragma mark - Private Methods

- (BOOL)isDirty {
    return ![self.previousTitle isEqualToString:self.morselTitleTextView.text];
}

#pragma mark - UIKeyboard Notification Methods

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary* info = [notification userInfo];
    CGRect kbRect = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    kbRect = [self.view convertRect:kbRect
                           fromView:nil];
    self.countLimitConstraint.constant = kbRect.size.height + 10.f;
    self.textBottomConstraint.constant = kbRect.size.height;
    [self.view setNeedsUpdateConstraints];
    [UIView animateWithDuration:.25f
                     animations:^{
                         [self.view layoutIfNeeded];
                     }];
}

#pragma mark - UITextViewDelegate Methods

- (void)textViewDidChange:(UITextView *)textView {
    NSUInteger textLength = textView.text.length;
    _doneBarButtonItem.enabled = [self isDirty];
    _titlePlaceholderLabel.hidden = !(textLength == 0);
    if (textLength < MRSLMorselTitleThreshold) {
        [_titleCountLimitLabel setTextColor:[UIColor morselValidColor]];
    } else if (textLength >= MRSLMorselTitleThreshold && textLength <= MRSLMorselTitleMaxCount) {
        [_titleCountLimitLabel setTextColor:[UIColor morselInvalidColor]];
    }
    NSUInteger remainingTextLength = MRSLMorselTitleMaxCount - textLength;
    _titleCountLimitLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)remainingTextLength];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSUInteger textLength = (textView.text.length - range.length) + text.length;
    if ([text isEqualToString:@"\n"]) {
        [self done:nil];
        return NO;
    } else if (textLength > MRSLMorselTitleMaxCount) {
        return NO;
    }
    return YES;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Discard"]) {
        [super goBack];
    }
}

#pragma mark - Dealloc

- (void)reset {
    [super reset];
    self.morselTitleTextView.delegate = nil;
    self.morselTitleTextView.placeholder = nil;
    self.morselTitleTextView.placeholderColor = nil;
}

@end
