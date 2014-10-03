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
    self.isPerformingRequest = YES;
    [[MRSLEventManager sharedManager] track:@"Tapped Button"
                                 properties:@{@"_title": @"Done",
                                              @"_view": self.mp_eventView}];
        MRSLMorsel *morsel = [self getOrLoadMorselIfExists];
        if (morsel) {
            if (![morsel.title isEqualToString:self.morselTitleTextView.text]) {
                morsel.title = self.morselTitleTextView.text;
                __weak __typeof(self) weakSelf = self;
                [_appDelegate.apiService updateMorsel:morsel
                                              success:^(id responseObject) {
                                                  [weakSelf.navigationController popViewControllerAnimated:YES];
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

#pragma mark - UITextViewDelegate Methods

- (void)textViewDidChange:(UITextView *)textView {
    NSUInteger textLength = textView.text.length;
    _doneBarButtonItem.enabled = [self isDirty];
    _titlePlaceholderLabel.hidden = !(textLength == 0);
    if (textLength < 40) {
        [_titleCountLimitLabel setTextColor:[UIColor morselValidColor]];
    } else if (textLength >= 40 && textLength <= 50) {
        [_titleCountLimitLabel setTextColor:[UIColor morselInvalidColor]];
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