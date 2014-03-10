//
//  MRSLStoryAddDescriptionViewController.m
//  Morsel
//
//  Created by Javier Otero on 3/6/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLStoryEditDescriptionViewController.h"

#import <GCPlaceholderTextView/GCPlaceholderTextView.h>

#import "MRSLMorsel.h"

@interface MRSLStoryEditDescriptionViewController ()
<UITextViewDelegate>

@property (weak, nonatomic) IBOutlet GCPlaceholderTextView *morselDescriptionTextView;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneBarButtonItem;

@property (strong, nonatomic) MRSLMorsel *morsel;

@end

@implementation MRSLStoryEditDescriptionViewController

#pragma mark - Instance Methods

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.morsel = [self getOrLoadMorselIfExists];

    self.morselDescriptionTextView.text = _morsel.morselDescription;
    self.morselDescriptionTextView.placeholder = @"What's interesting about this?";
    [self.morselDescriptionTextView becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [self.view endEditing:YES];
}

#pragma mark - Private Methods

- (MRSLMorsel *)getOrLoadMorselIfExists {
    if (_morselID) self.morsel = [MRSLMorsel MR_findFirstByAttribute:MRSLMorselAttributes.morselID
                                                     withValue:_morselID];
    if (_morselLocalUUID) self.morsel = [MRSLMorsel MR_findFirstByAttribute:MRSLMorselAttributes.localUUID
                                                             withValue:_morselLocalUUID];
    return _morsel;
}

#pragma mark - Action Methods

- (IBAction)cancel:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)done:(id)sender {
    self.morsel = [self getOrLoadMorselIfExists];
    if (![_morsel.morselDescription isEqualToString:self.morselDescriptionTextView.text]) {
        _morsel.morselDescription = self.morselDescriptionTextView.text;
        _morsel.isUploading = @YES;
        [_appDelegate.morselApiService updateMorsel:_morsel
                                            andPost:nil
                                            success:nil
                                            failure:nil];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITextViewDelegate Methods

- (void)textViewDidChange:(UITextView *)textView {
    NSUInteger textLength = textView.text.length;
    _doneBarButtonItem.enabled = !(textLength == 0);
}

@end