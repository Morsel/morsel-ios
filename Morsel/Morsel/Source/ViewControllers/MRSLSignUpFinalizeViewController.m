//
//  MRSLSignUpFinalizeViewController.m
//  Morsel
//
//  Created by Javier Otero on 5/7/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLSignUpFinalizeViewController.h"

#import "MRSLAPIService+Registration.h"

#import "GCPlaceholderTextView.h"
#import "MRSLUserIndustryTableViewCell.h"

#import "MRSLUser.h"

@interface MRSLSignUpFinalizeViewController ()
<UITableViewDataSource,
UITableViewDelegate,
UITextViewDelegate>

@property (weak, nonatomic) IBOutlet GCPlaceholderTextView *bioTextView;

@property (weak, nonatomic) IBOutlet UILabel *bioLimitLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;

@property (nonatomic) MRSLIndustryType industryType;

@property (strong, nonatomic) NSArray *industries;
@property (strong, nonatomic) NSArray *industryTypes;

@end

@implementation MRSLSignUpFinalizeViewController

#pragma mark - Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];

    self.signUpButton.enabled = NO;
    self.industries = @[@"Restaurant Professional", @"Media", @"Diner"];
    self.industryTypes = @[@(MRSLIndustryTypeChef), @(MRSLIndustryTypeMedia), @(MRSLIndustryTypeDiner)];

    [self.bioTextView setBorderWithColor:[UIColor morselLightContent]
                                andWidth:1.f];
    self.bioTextView.placeholder = @"Southern food fanatic, love bacon and a good bourbon.";
    self.bioTextView.placeholderColor = [UIColor morselLightContent];
}

- (void)viewWillAppear:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarHidden:YES
                                            withAnimation:UIStatusBarAnimationSlide];
    [self.navigationController setNavigationBarHidden:YES
                                             animated:animated];
    [super viewWillAppear:animated];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
}

#pragma mark - Action Methods

- (IBAction)completeSignUp {
    if ([_bioTextView.text length] > 0) {
        [_appDelegate.apiService updateUserBio:[MRSLUser currentUser]
                                       success:nil
                                       failure:nil];
    }
    [_appDelegate.apiService updateUserIndustry:[MRSLUser currentUser]
                                        success:^(id responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:MRSLServiceDidLogInUserNotification
                                                                object:nil];
        });
    } failure:^(NSError *error) {
        MRSLServiceErrorInfo *serviceErrorInfo = error.userInfo[JSONResponseSerializerWithServiceErrorInfoKey];
        [UIAlertView showAlertViewForServiceError:serviceErrorInfo
                                         delegate:nil];
    }];
}

#pragma mark - UITextViewDelegate Methods

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([textView isEqual:_bioTextView]) {
        [[MRSLEventManager sharedManager] track:@"Tapped Bio Field"
                                     properties:@{@"view": @"Sign up"}];
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    NSUInteger textLength = textView.text.length;
    if (textLength < 150) {
        [_bioLimitLabel setTextColor:[UIColor morselGreen]];
    } else if (textLength >= 150 && textLength <= 160) {
        [_bioLimitLabel setTextColor:[UIColor morselRed]];
    }
    NSUInteger remainingTextLength = 160 - textLength;
    _bioLimitLabel.text = [NSString stringWithFormat:@"%lu/160", (unsigned long)remainingTextLength];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSUInteger textLength = (textView.text.length - range.length) + text.length;
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        [MRSLUser currentUser].bio = textView.text;
        return NO;
    } else if (textLength > 160) {
        return NO;
    }
    return YES;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_industries count];
}

- (MRSLUserIndustryTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *industry = [_industries objectAtIndex:indexPath.row];
    MRSLUserIndustryTableViewCell *industryCell = [tableView dequeueReusableCellWithIdentifier:@"ruid_IndustryCell"];
    industryCell.nameLabel.text = industry;
    industryCell.pipeView.hidden = (indexPath.row == [_industries count] - 1);
    return industryCell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![self.signUpButton isEnabled]) {
        self.signUpButton.enabled = YES;
    }
    [MRSLUser currentUser].industryTypeEnum = [[_industryTypes objectAtIndex:indexPath.row] integerValue];
}

@end
