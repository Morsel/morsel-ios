//
//  PostMorselsViewController.m
//  Morsel
//
//  Created by Javier Otero on 1/28/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "PostMorselsViewController.h"

#import "CreateMorselViewController.h"
#import "PostMorselCollectionViewCell.h"

#import "MRSLMorsel.h"
#import "MRSLPost.h"

@interface PostMorselsViewController ()
<UIAlertViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegate,
UITextFieldDelegate>

@property (nonatomic) int postID;

@property (nonatomic, strong) NSArray *morsels;

@property (nonatomic, weak) IBOutlet UICollectionView *postMorselsCollectionView;
@property (weak, nonatomic) IBOutlet UITextField *postTitleLabel;

@end

@implementation PostMorselsViewController

#pragma mark - Instance Methods

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (_post) {
        self.postID = [_post.postID intValue];
    } else {
        self.post = [MRSLPost MR_findFirstByAttribute:MRSLPostAttributes.postID
                                            withValue:@(_postID)
                                            inContext:[NSManagedObjectContext MR_defaultContext]];
    }

    self.postTitleLabel.text = _post.title;

    if (!_post.title)
        _post.title = @"";

    [self.postMorselsCollectionView reloadData];

    self.morsels = self.post.morselsArray;

    if ([_morsels count] == 0) {
        [self.presentingViewController dismissViewControllerAnimated:YES
                                                          completion:nil];
    }
}

#pragma mark - Private Methods

- (IBAction)cancelEditing:(id)sender {
    if (![_post.title isEqualToString:_postTitleLabel.text]) {
        UIAlertView *postChangesAlert = [[UIAlertView alloc] initWithTitle:@"Update Post?"
                                                                   message:@"Would you like to save your changes?"
                                                                  delegate:self
                                                         cancelButtonTitle:@"NO"
                                                         otherButtonTitles:@"YES", nil];

        [postChangesAlert show];
    } else {
        [self.presentingViewController dismissViewControllerAnimated:YES
                                                          completion:nil];
    }
}

#pragma mark - UICollectionViewDataSource Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_morsels count];
}

- (PostMorselCollectionViewCell *)collectionView:(UICollectionView *)collectionView
                          cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MRSLMorsel *morsel = [_morsels objectAtIndex:indexPath.row];

    PostMorselCollectionViewCell *postMorselCell = [self.postMorselsCollectionView dequeueReusableCellWithReuseIdentifier:@"PostMorselCell"
                                                                                                             forIndexPath:indexPath];
    postMorselCell.morsel = morsel;

    return postMorselCell;
}

#pragma mark - UICollectionViewDelegate Methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    MRSLMorsel *morsel = [_morsels objectAtIndex:indexPath.row];

    [[Mixpanel sharedInstance] track:@"Tapped Edit Morsel"
                          properties:@{@"view": @"PostMorselsViewController",
                                       @"morsel_id": morsel.morselID ?: @"No Server ID"}];

    CreateMorselViewController *createMorselVC = [[UIStoryboard morselManagementStoryboard] instantiateViewControllerWithIdentifier:@"CreateMorselViewController"];
    createMorselVC.morsel = morsel;

    [self.navigationController pushViewController:createMorselVC
                                         animated:YES];
}

#pragma mark - UITextFieldDelegate Methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];

        return NO;
    } else {
        return YES;
    }

    return YES;
}

#pragma mark - UIAlertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [[Mixpanel sharedInstance] track:@"Tapped Update Post"
                              properties:@{@"view": @"PostMorselsViewController",
                                           @"post_id": _post.postID ?: @"No Server ID"}];
        _post.title = _postTitleLabel.text;

        [_appDelegate.morselApiService updatePost:_post
                                         success:nil
                                         failure:nil];
    }

    [self.presentingViewController dismissViewControllerAnimated:YES
                                                      completion:nil];
}

@end
