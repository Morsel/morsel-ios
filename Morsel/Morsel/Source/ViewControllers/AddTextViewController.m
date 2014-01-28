//
//  AddTextViewController.m
//  Morsel
//
//  Created by Javier Otero on 1/29/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "AddTextViewController.h"

#import "GCPlaceholderTextView.h"

@interface AddTextViewController ()

<
UITextViewDelegate
>

@end

@implementation AddTextViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _textView.placeholder = @"Tap to add text";
}

#pragma mark - UITextViewDelegate Methods

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self.textView setHeight:180.f];
    
    if ([self.delegate respondsToSelector:@selector(addTextViewDidBeginEditing)])
    {
        [self.delegate addTextViewDidBeginEditing];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [self.textView setHeight:264.f];
}

@end