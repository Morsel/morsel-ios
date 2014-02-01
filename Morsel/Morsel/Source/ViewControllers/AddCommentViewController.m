//
//  AddCommentViewController.m
//  Morsel
//
//  Created by Javier Otero on 1/31/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "AddCommentViewController.h"

#import <GCPlaceholderTextView/GCPlaceholderTextView.h>

#import "ModelController.h"

#import "MRSLComment.h"

@interface AddCommentViewController ()
    <UITextViewDelegate>

@property (nonatomic, weak) IBOutlet GCPlaceholderTextView *placeholderTextView;

@end

@implementation AddCommentViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    self.placeholderTextView.placeholder = @"Add a comment...";
    
    [self.placeholderTextView becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.placeholderTextView resignFirstResponder];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [self.placeholderTextView setHeight:self.view.frame.size.height - keyboardSize.height];
}

#pragma mark - Private Methods

- (IBAction)postComment {
    if (_placeholderTextView.text.length > 0 && _morsel) {
        MRSLComment *comment = [MRSLComment MR_createInContext:[ModelController sharedController].defaultContext];
        comment.text = _placeholderTextView.text;
        comment.morsel = _morsel;
        comment.user = [ModelController sharedController].currentUser;
        
        [[ModelController sharedController].morselApiService postComment:comment
                                                                 success:nil
                                                                 failure:nil];
        [self.presentingViewController dismissViewControllerAnimated:YES
                                                          completion:nil];

    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Sorry, you can't submit a comment without text!"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (IBAction)cancelComment {
    [self.presentingViewController dismissViewControllerAnimated:YES
                                                      completion:nil];
}

#pragma mark - UITextViewDelegate Methods

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [self postComment];
        return NO;
    } else {
        return YES;
    }
    
    return YES;
}

#pragma mark - Destroy Methods

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
