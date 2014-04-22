//
//  MRSLProfileEditViewController.m
//  Morsel
//
//  Created by Javier Otero on 4/22/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLProfileEditViewController.h"

#import <GCPlaceholderTextView/GCPlaceholderTextView.h>

#import "MRSLProfileImageView.h"

#import "MRSLUser.h"

@interface MRSLProfileEditViewController ()
<UITextFieldDelegate,
UITextViewDelegate>

@property (nonatomic) CGFloat scrollViewContentHeight;

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UITextField *firstNameField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *titleField;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;

@property (weak, nonatomic) IBOutlet GCPlaceholderTextView *bioTextView;
@property (weak, nonatomic) IBOutlet MRSLProfileImageView *profileImageView;

@property (strong, nonatomic) IBOutletCollection(NSObject) NSArray *requiredFields;

@end

@implementation MRSLProfileEditViewController

#pragma mark - Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

    self.scrollViewContentHeight = [_logoutButton getHeight] + [_logoutButton getY] + 20.f;
    _bioTextView.placeholder = @"Biography";
    self.scrollView.contentSize = CGSizeMake([self.view getWidth], _scrollViewContentHeight);

    [self populateContent];
}

- (void)setUser:(MRSLUser *)user {
    if (_user != user) {
        _user = user;
        [self populateContent];
    }
}

#pragma mark - Private Methods

- (void)populateContent {
    self.profileImageView.user = _user;
    self.usernameLabel.text = _user.username;
    self.firstNameField.text = _user.first_name;
    self.lastNameField.text = _user.last_name;
    self.emailField.text = _user.email;
    self.titleField.text = _user.title;
    self.bioTextView.text = _user.bio;
}

- (void)focusScrollViewToFrame:(CGRect)frame {
    frame.origin.y = frame.origin.y - ([_scrollView getHeight] / 2);
    [_scrollView scrollRectToVisible:frame
                            animated:YES];
}

#pragma mark - Notification Methods

- (void)keyboardWillShow:(NSNotification *)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    [UIView animateWithDuration:.2f
                     animations:^{
                         [self.scrollView setHeight:[self.view getHeight] - keyboardSize.height];
                     }];
}

- (void)keyboardWillHide {
    [UIView animateWithDuration:.2f
                     animations:^{
                         [self.scrollView setHeight:[self.view getHeight]];
                     }];
}

#pragma mark - Action Methods

- (IBAction)logout {
    [[NSNotificationCenter defaultCenter] postNotificationName:MRSLServiceShouldLogOutUserNotification
                                                        object:nil];
}

- (IBAction)updateProfile {
    BOOL fieldsFilled = YES;
    for (NSObject *requiredField in _requiredFields) {
        if ([requiredField respondsToSelector:@selector(text)]) {
            if ([[(UITextField *)requiredField text] length] == 0) {
                [(UIView *)requiredField setBorderWithColor:[UIColor morselRed]
                                                   andWidth:2.f];
                fieldsFilled = NO;
            } else {
                [(UIView *)requiredField setBorderWithColor:nil
                                                   andWidth:0.f];
            }
        }
    }
    if (!fieldsFilled) {
        [UIAlertView showAlertViewForErrorString:@"Please fill in all fields."
                                        delegate:nil];
        return;
    }

    BOOL userDidUpdate = (_user.first_name) ? ![_user.first_name isEqualToString:_firstNameField.text] : (![_firstNameField.text length] == 0);
    userDidUpdate = (_user.last_name) ? ![_user.last_name isEqualToString:_lastNameField.text] : (![_lastNameField.text length] == 0);
    userDidUpdate = (_user.email) ? ![_user.email isEqualToString:_emailField.text] : (![_emailField.text length] == 0);
    userDidUpdate = (_user.title) ? ![_user.title isEqualToString:_titleField.text] : (![_titleField.text length] == 0);
    userDidUpdate = (_user.bio) ? ![_user.bio isEqualToString:_bioTextView.text] : (![_bioTextView.text length] == 0);

    if (userDidUpdate) {
        _user.first_name = _firstNameField.text;
        _user.last_name = _lastNameField.text;
        _user.email = _emailField.text;
        _user.title = _titleField.text;
        _user.bio = _bioTextView.text;

        __weak __typeof(self) weakSelf = self;
        [_appDelegate.apiService updateUser:_user
                                    success:^(id responseObject) {
                                        [weakSelf goBack];
                                    } failure:nil];
    } else {
        [self goBack];
    }
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self focusScrollViewToFrame:textField.frame];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
        return NO;
    }
    return YES;
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [self focusScrollViewToFrame:textView.frame];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSUInteger textLength = (textView.text.length - range.length) + text.length;
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    } else if (textLength > 255) {
        return NO;
    }
    return YES;
}

#pragma mark - Dealloc

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
