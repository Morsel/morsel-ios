//
//  PostMorselsViewController.m
//  Morsel
//
//  Created by Javier Otero on 1/28/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "PostMorselsViewController.h"

#import "CreateMorselViewController.h"
#import "ModelController.h"
#import "PostMorselCollectionViewCell.h"

#import "MRSLMorsel.h"
#import "MRSLPost.h"

@interface PostMorselsViewController ()
    <UIAlertViewDelegate,
     UICollectionViewDataSource,
     UICollectionViewDelegate,
     UITextFieldDelegate>

@property (nonatomic) int postID;

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
        self.post = [[ModelController sharedController] postWithID:[NSNumber numberWithInt:_postID]];
    }

    self.postTitleLabel.text = _post.title;

    if (!_post.title)
        _post.title = @"";

    [self.postMorselsCollectionView reloadData];
    
    if ([self.post.morsels count] == 0) {
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
    return [_post.morsels count];
}

- (PostMorselCollectionViewCell *)collectionView:(UICollectionView *)collectionView
                         cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MRSLMorsel *morsel = [_post.morsels objectAtIndex:indexPath.row];

    PostMorselCollectionViewCell *postMorselCell = [self.postMorselsCollectionView dequeueReusableCellWithReuseIdentifier:@"PostMorselCell"
                                                                                                             forIndexPath:indexPath];
    postMorselCell.morsel = morsel;

    return postMorselCell;
}

#pragma mark - UICollectionViewDelegate Methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    MRSLMorsel *morsel = [_post.morsels objectAtIndex:indexPath.row];

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
        _post.title = _postTitleLabel.text;

        [[ModelController sharedController].morselApiService updatePost:_post
                                                                success:^(id responseObject)
        {
            [[ModelController sharedController] saveDataToStoreWithSuccess:nil
                                                                   failure:nil];
        }
    failure:nil];
    }

    [self.presentingViewController dismissViewControllerAnimated:YES
                                                      completion:nil];
}

@end
