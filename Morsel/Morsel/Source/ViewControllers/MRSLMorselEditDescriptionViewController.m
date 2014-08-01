//
//  MRSLMorselAddDescriptionViewController.m
//  Morsel
//
//  Created by Javier Otero on 3/6/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLMorselEditDescriptionViewController.h"

#import <GCPlaceholderTextView/GCPlaceholderTextView.h>

#import "MRSLAPIService+Item.h"

#import "MRSLItem.h"

@interface MRSLMorselEditDescriptionViewController ()
<UIAlertViewDelegate,
UITextViewDelegate>

@property (weak, nonatomic) IBOutlet GCPlaceholderTextView *itemDescriptionTextView;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneBarButtonItem;

@property (strong, nonatomic) MRSLItem *item;

@end

@implementation MRSLMorselEditDescriptionViewController

#pragma mark - Instance Methods

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.mp_eventView = @"edit_item_description";

    self.item = [self getOrLoadMorselIfExists];

    self.itemDescriptionTextView.text = _item.itemDescription;
    self.itemDescriptionTextView.placeholder = @"What's interesting about this?";
    [self.itemDescriptionTextView becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [self.view endEditing:YES];
}

#pragma mark - Private Methods

- (MRSLItem *)getOrLoadMorselIfExists {
    if (_itemID) self.item = [MRSLItem MR_findFirstByAttribute:MRSLItemAttributes.itemID
                                                     withValue:_itemID];
    return _item;
}

#pragma mark - Action Methods

- (void)goBack {
    if (![_item.itemDescription ?: @"" isEqualToString:self.itemDescriptionTextView.text]) {
        [UIAlertView showAlertViewWithTitle:@"Discard Changes?"
                                    message:@"If you go back, you'll lose all your changes. Are you sure you want to do this?"
                                   delegate:self
                          cancelButtonTitle:@"No"
                          otherButtonTitles:@"Yes", nil];
    } else {
        [super goBack];
    }
}

- (IBAction)done:(id)sender {
    self.item = [self getOrLoadMorselIfExists];
    if (!self.item.itemID) return;
    [[MRSLEventManager sharedManager] track:@"Tapped Button"
                                 properties:@{@"_title": @"Done",
                                              @"_view": self.mp_eventView,
                                              @"char_count": @([_itemDescriptionTextView.text length]),
                                              @"item_id": NSNullIfNil(_item.itemID)}];
    if (![_item.itemDescription isEqualToString:self.itemDescriptionTextView.text]) {
        _item.itemDescription = self.itemDescriptionTextView.text;
        [_appDelegate.apiService updateItem:_item
                                  andMorsel:nil
                                    success:nil
                                    failure:nil];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    NSUInteger textLength = textView.text.length;
    _doneBarButtonItem.enabled = !(textLength == 0);
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Yes"]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Dealloc

- (void)reset {
    [super reset];
    self.itemDescriptionTextView.delegate = nil;
    self.itemDescriptionTextView.placeholder = nil;
    self.itemDescriptionTextView.placeholderColor = nil;
}

@end
