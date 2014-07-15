//
//  MRSLMorselTitleViewController.m
//  Morsel
//
//  Created by Javier Otero on 3/3/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLMorselAddTitleViewController.h"

#import <GCPlaceholderTextView/GCPlaceholderTextView.h>

#import "MRSLAPIService+Morsel.h"

#import "MRSLMorselEditViewController.h"

#import "MRSLMorsel.h"

@interface MRSLMorselAddTitleViewController ()
<UITextViewDelegate>

@property (weak, nonatomic) IBOutlet GCPlaceholderTextView *morselTitleTextView;

@property (weak, nonatomic) IBOutlet UILabel *titleCountLimitLabel;
@property (weak, nonatomic) IBOutlet UILabel *titlePlaceholderLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneBarButtonItem;

@end

@implementation MRSLMorselAddTitleViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    if (_morselID) {
        MRSLMorsel *morsel = [self getOrLoadMorselIfExists];
        self.morselTitleTextView.text = morsel.title;
        [self textViewDidChange:_morselTitleTextView];
        self.title = @"Edit Morsel title";
    } else {
        self.title = @"Give your Morsel a title";
    }

    self.morselTitleTextView.placeholder = @"What are you working on?";
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

- (IBAction)done:(id)sender {
    [self.doneBarButtonItem setEnabled:NO];
    [self.titlePlaceholderLabel setHidden:YES];
    [self.view endEditing:YES];
    [[MRSLEventManager sharedManager] track:@"Tapped Done"
                                 properties:@{@"view": @"Add Morsel Title"}];
    if (_isUserEditingTitle) {
        MRSLMorsel *morsel = [self getOrLoadMorselIfExists];
        if (morsel) {
            if (![morsel.title isEqualToString:self.morselTitleTextView.text]) {
                morsel.title = self.morselTitleTextView.text;
                    [_appDelegate.apiService updateMorsel:morsel
                                                  success:nil
                                                  failure:nil];
            }
        } else {
            [UIAlertView showAlertViewForErrorString:@"Unable to update Morsel! Please try again."
                                            delegate:nil];
        }
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        MRSLMorsel *morsel = [MRSLMorsel MR_createEntity];
        morsel.draft = @YES;
        morsel.title = self.morselTitleTextView.text;

        __weak __typeof(self) weakSelf = self;
        [_appDelegate.apiService createMorsel:morsel
                                      success:^(id responseObject) {
                                          MRSLMorselEditViewController *editMorselVC = [[UIStoryboard morselManagementStoryboard] instantiateViewControllerWithIdentifier:@"sb_MRSLMorselEditViewController"];
                                          editMorselVC.shouldPresentMediaCapture = YES;
                                          editMorselVC.morselID = morsel.morselID;
                                          [weakSelf.navigationController pushViewController:editMorselVC
                                                                                   animated:YES];
                                      } failure:^(NSError *error) {
                                          [UIAlertView showAlertViewForErrorString:@"Unable to create Morsel! Please try again."
                                                                          delegate:nil];
                                          [morsel MR_deleteEntity];
                                          [weakSelf.doneBarButtonItem setEnabled:YES];
                                          [weakSelf.titlePlaceholderLabel setHidden:NO];
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
