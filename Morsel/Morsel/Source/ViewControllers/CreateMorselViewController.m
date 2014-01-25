//
//  CreateMorselViewController.m
//  Morsel
//
//  Created by Javier Otero on 12/13/13.
//  Copyright (c) 2013 Morsel. All rights reserved.
//

#import "CreateMorselViewController.h"

#import <MobileCoreServices/MobileCoreServices.h>

#import "ModelController.h"
#import "MorselCardCollectionViewCell.h"
#import "JSONResponseSerializerWithData.h"

#import "MRSLMorsel.h"
#import "MRSLPost.h"
#import "MRSLUser.h"

@interface CreateMorselViewController ()

<
UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
UITextFieldDelegate,
MorselCardCollectionViewCellDelegate
>

@property (nonatomic, weak) IBOutlet UIBarButtonItem *cancelButtonItem;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *postButtonItem;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, weak) IBOutlet UITextField *titleField;

@property (nonatomic, strong) UIImagePickerController *imagePickerController;

@property (nonatomic, weak) MorselCardCollectionViewCell *selectedMorselCard;
@property (nonatomic, strong) MRSLPost *post;

@end

@implementation CreateMorselViewController

#pragma mark - Instance Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    MRSLMorsel *morsel = [MRSLMorsel MR_createInContext:[ModelController sharedController].defaultContext];
    
    self.post = [MRSLPost MR_createInContext:[ModelController sharedController].defaultContext];
    [self.post addMorsel:morsel];
    
    [self.cancelButtonItem setTarget:self];
    [self.postButtonItem setTarget:self];
    
    [self.cancelButtonItem setAction:@selector(cancelMorsel)];
    [self.postButtonItem setAction:@selector(postMorsel)];
    
    __weak typeof (self) weakSelf = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^
    {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.allowsEditing = NO;
        //imagePicker.videoMaximumDuration = 10.f;
        imagePicker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeImage, /*(NSString *)kUTTypeMovie,*/ nil];
        
        imagePicker.delegate = self;
        
        weakSelf.imagePickerController = imagePicker;
    });
    
}

- (IBAction)postMorsel
{
    if ([_post.morsels count] == 1)
    {
        MRSLMorsel *firstMorsel = [_post.morsels firstObject];
        
        if (!firstMorsel.morselDescription && !firstMorsel.morselPicture)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Post Error."
                                                            message:@"Please add content to the Morsel."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            
            [alert show];
            return;
        }
    }
    
    int i = 0;
    
    for (MRSLMorsel *morsel in _post.morsels)
    {
        morsel.sortOrder = [NSNumber numberWithInt:i];
        i ++;
        
        DDLogDebug(@"Morsel Sort Order: %i", [morsel.sortOrder intValue]);
    }
    
    [[[ModelController sharedController] currentUser] addPost:self.post];
    
    [[ModelController sharedController].morselApiService createPost:_post
                                                            success:^(id responseObject)
    {
        [[ModelController sharedController].defaultContext MR_saveOnlySelfWithCompletion:^(BOOL success, NSError *error)
        {
            if (error)
            {
                DDLogError(@"Error creating post.");
#warning If saving post locally fails, what course of action should be taken?
            }
            else
            {
                DDLogDebug(@"New Post created!");
            }
        }];
        
        [self.presentingViewController dismissViewControllerAnimated:YES
                                                          completion:nil];
    }
                                                            failure:^(NSError *error)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Post Failed. Please try again."
                                                        message:[NSString stringWithFormat:@"Error: %@", error.userInfo[JSONResponseSerializerWithDataKey]]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        
        [alert show];
    }];
}

- (IBAction)cancelMorsel
{
    
    [[ModelController sharedController].defaultContext deleteObject:_post];
    
    [self.presentingViewController dismissViewControllerAnimated:YES
                                                      completion:nil];
}

- (void)endMorselTextEditing
{
    [self.view endEditing:YES];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.post.morsels count] + 1;
}

- (MorselCardCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MorselCardCollectionViewCell *morselCell = nil;
    
    if (indexPath.row == [self.post.morsels count])
    {
        morselCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"AddMorselCell"
                                                                    forIndexPath:indexPath];
    }
    else
    {
        morselCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"CreateMorselCell"
                                                                    forIndexPath:indexPath];
        morselCell.delegate = self;
        
        MRSLMorsel *morsel = [self.post.morsels objectAtIndex:indexPath.row];
        morselCell.morsel = morsel;
    }
    
    return morselCell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    MRSLMorsel *lastExistingMorsel = [self.post.morsels lastObject];
    
    if (lastExistingMorsel.morselPicture || lastExistingMorsel.morselDescription)
    {
        MRSLMorsel *morsel = [MRSLMorsel MR_createInContext:[ModelController sharedController].defaultContext];
        
        [self.post addMorsel:morsel];
        
        [self.collectionView reloadData];
        
        [self.titleField setEnabled:YES];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Append Morsel Error."
                                                        message:@"Please add an image or text to your previous Morsel first."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        
        [alert show];
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [self.post.morsels count])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [self.post.morsels count])
    {
        return CGSizeMake(320.f, 50.f);
    }
    else
    {
        return CGSizeMake(320.f, 200.f);
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if ([info[UIImagePickerControllerMediaType] isEqualToString:(NSString *)kUTTypeImage])
    {
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        
        [self.selectedMorselCard updateMedia:image];
    }
    
    self.selectedMorselCard = nil;
    
    [self dismissViewControllerAnimated:YES
                             completion:nil];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    self.selectedMorselCard = nil;
    
    [self dismissViewControllerAnimated:YES
                             completion:nil];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

#pragma mark - MorselCardCollectionViewCellDelegate

- (void)morselCardDidSelectAddMedia:(MorselCardCollectionViewCell *)card
{
    [self endMorselTextEditing];
    
    self.selectedMorselCard = card;
    
    [self presentViewController:_imagePickerController
                       animated:YES
                     completion:nil];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)morselCard:(MorselCardCollectionViewCell *)card didUpdateDescription:(NSString *)description
{
    self.selectedMorselCard = nil;
    
    [self.cancelButtonItem setTarget:self];
    [self.postButtonItem setTarget:self];
    
    [self.cancelButtonItem setAction:@selector(cancelMorsel)];
    [self.postButtonItem setAction:@selector(postMorsel)];
    
    [self.cancelButtonItem setTitle:@"Cancel"];
    [self.postButtonItem setTitle:@"Post"];
}

- (void)morselCardDidBeginEditing:(MorselCardCollectionViewCell *)card
{
    self.selectedMorselCard = card;
    
    [self.cancelButtonItem setTarget:self];
    [self.postButtonItem setTarget:self];
    
    [self.postButtonItem setAction:@selector(endMorselTextEditing)];
    
    [self.cancelButtonItem setTitle:@""];
    [self.postButtonItem setTitle:@"Done"];
}

- (void)morselCardShouldDelete:(MorselCardCollectionViewCell *)card
{
    if (self.post.morsels.count > 1)
    {
        NSIndexPath *cellPath = [self.collectionView indexPathForCell:card];
        
        MRSLMorsel *morsel = [self.post.morselsSet objectAtIndex:cellPath.row];
        [self.post.morselsSet removeObject:morsel];
        
        [[ModelController sharedController].defaultContext deleteObject:morsel];
        
        [self.collectionView reloadData];
        
        if ([self.post.morsels count] == 1)
        {
            [self.titleField setEnabled:NO];
        }
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You cannot delete your only Morsel." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alert show];
    }
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.text)
    {
        self.post.title = textField.text;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"])
    {
        [textField resignFirstResponder];
        return NO;
    }
    else
    {
        return YES;
    }
}

@end
