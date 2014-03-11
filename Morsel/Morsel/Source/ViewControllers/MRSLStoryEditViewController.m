//
//  MRSLStoryEditViewController.m
//  Morsel
//
//  Created by Javier Otero on 3/4/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLStoryEditViewController.h"

#import <NSDate+TimeAgo/NSDate+TimeAgo.h>

#import "MRSLCaptureMediaViewController.h"
#import "MRSLImagePreviewViewController.h"
#import "MRSLStoryAddTitleViewController.h"
#import "MRSLStoryEditMorselTableViewCell.h"
#import "MRSLStoryEditDescriptionViewController.h"
#import "MRSLStorySettingsViewController.h"

#import "MRSLMediaItem.h"

#import "MRSLMorsel.h"
#import "MRSLPost.h"

@interface MRSLStoryEditViewController ()
<NSFetchedResultsControllerDelegate,
UIAlertViewDelegate,
UITableViewDataSource,
UITableViewDelegate,
CaptureMediaViewControllerDelegate,
MRSLStoryEditMorselTableViewCellDelegate>

@property (nonatomic) BOOL shouldShowAddCell;
@property (nonatomic) BOOL wasNewStory;
@property (nonatomic) BOOL navigationBarWasHidden;

@property (weak, nonatomic) IBOutlet UIButton *storyTitleButton;
@property (weak, nonatomic) IBOutlet UILabel *storyTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastUpdatedLabel;
@property (weak, nonatomic) IBOutlet UITableView *storyMorselsTableView;

@property (strong, nonatomic) NSDateFormatter *statusDateFormatter;
@property (strong, nonatomic) NSFetchedResultsController *morselsFetchedResultsController;
@property (strong, nonatomic) NSMutableArray *morsels;

@property (weak, nonatomic) MRSLPost *post;
@property (weak, nonatomic) MRSLMorsel *morsel;

@end

@implementation MRSLStoryEditViewController

#pragma mark - Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];

    self.shouldShowAddCell = YES;
    self.morsels = [NSMutableArray array];
    self.statusDateFormatter = [[NSDateFormatter alloc] init];
    [_statusDateFormatter setDateFormat:@"h:mm a"];

    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon-back"]
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(goBack)];
    [self.navigationItem setLeftBarButtonItem:backButton];

    [self displayStory];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self displayStory];

    if (self.navigationController.navigationBarHidden) {
        self.navigationBarWasHidden = YES;
        [self.navigationController setNavigationBarHidden:NO
                                                 animated:YES];
    }
    if (_shouldPresentMediaCapture) {
        self.wasNewStory = YES;
        self.shouldPresentMediaCapture = NO;
        [self presentMediaCapture];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (_navigationBarWasHidden) {
        [self.navigationController setNavigationBarHidden:YES
                                                 animated:YES];
    }
}

- (void)displayStory {
    [self getOrLoadPostIfExists];

    if (_post.draftValue) {
        UIBarButtonItem *publishButton = [[UIBarButtonItem alloc] initWithTitle:@"Publish"
                                                                          style:UIBarButtonItemStyleBordered
                                                                         target:self
                                                                         action:@selector(publishStory)];
        [self.navigationItem setRightBarButtonItem:publishButton];
    }

    self.storyTitleLabel.text = ([_post.title length] == 0) ? @"Tap to add title" : _post.title;
    [self displayStoryStatus];

    if (!_postID || self.morselsFetchedResultsController) {
        [self.storyMorselsTableView reloadData];
        return;
    }

    [self setupMorselsFetchRequest];
    [self populateContent];
}

- (void)updateStoryStatus {
    if ([self getOrLoadPostIfExists]) {
        [_appDelegate.morselApiService getPost:_post
                                       success:nil
                                       failure:nil];
    }
}

- (void)displayStoryStatus {
    NSDate *lastUpdated = [_post latestUpdatedDate];
    self.lastUpdatedLabel.text = [NSString stringWithFormat:@"Last %@ at %@", @"updated", (lastUpdated) ? [_statusDateFormatter stringFromDate:lastUpdated] : [_statusDateFormatter stringFromDate:[NSDate date]]];
}

- (void)setupMorselsFetchRequest {
    NSPredicate *storyMorselsPredicate = [NSPredicate predicateWithFormat:@"(post.postID == %i)", [_postID intValue]];

    self.morselsFetchedResultsController = [MRSLMorsel MR_fetchAllSortedBy:@"sort_order"
                                                                 ascending:YES
                                                             withPredicate:storyMorselsPredicate
                                                                   groupBy:nil
                                                                  delegate:self
                                                                 inContext:[NSManagedObjectContext MR_defaultContext]];
}

- (void)populateContent {
    NSError *fetchError = nil;

    [_morselsFetchedResultsController performFetch:&fetchError];

    if (_morselsFetchedResultsController) {
        [self.morsels removeAllObjects];
        [self.morsels addObjectsFromArray:[_morselsFetchedResultsController fetchedObjects]];
    }

    [self.storyMorselsTableView reloadData];

    [self displayStoryStatus];
}

- (void)presentMediaCapture {
    MRSLCaptureMediaViewController *captureMediaVC = [[UIStoryboard mediaManagementStoryboard] instantiateViewControllerWithIdentifier:@"sb_MRSLCaptureMediaViewController"];
    captureMediaVC.delegate = self;
    [self presentViewController:captureMediaVC
                       animated:YES
                     completion:nil];
}

#pragma mark - Getter Methods

- (MRSLPost *)getOrLoadPostIfExists {
    if (_postID) self.post = [MRSLPost MR_findFirstByAttribute:MRSLPostAttributes.postID
                                                     withValue:_postID];
    return _post;
}

#pragma mark - Segue Methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"seg_EditMorselText"]) {
        MRSLStoryEditDescriptionViewController *morselEditTextVC = [segue destinationViewController];
        if (_morsel.morselID) {
            morselEditTextVC.morselID = _morsel.morselID;
        } else {
            morselEditTextVC.morselLocalUUID = _morsel.localUUID;
        }
    } else if ([segue.identifier isEqualToString:@"seg_EditStoryTitle"]) {
        MRSLStoryAddTitleViewController *storyAddTitleVC = [segue destinationViewController];
        storyAddTitleVC.isUserEditingTitle = YES;
        storyAddTitleVC.postID = _post.postID;
    } else if ([segue.identifier isEqualToString:@"seg_StorySettings"]) {
        MRSLStorySettingsViewController *storySettingsVC = [segue destinationViewController];
        storySettingsVC.post = _post;
    }
}

#pragma mark - Action Methods

- (IBAction)toggleEditing {
    [_storyMorselsTableView setEditing:!_storyMorselsTableView.editing
                              animated:YES];
    self.shouldShowAddCell = !_storyMorselsTableView.editing;
    NSIndexPath *addCellIndexPath = [NSIndexPath indexPathForItem:[_morsels count]
                                                        inSection:0];
    if (_shouldShowAddCell) [_storyMorselsTableView insertRowsAtIndexPaths:@[addCellIndexPath]
                                                          withRowAnimation:UITableViewRowAnimationFade];
    else  [_storyMorselsTableView deleteRowsAtIndexPaths:@[addCellIndexPath]
                                        withRowAnimation:UITableViewRowAnimationFade];
}

- (void)goBack {
    if (_wasNewStory) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)publishStory {
    [[MRSLEventManager sharedManager] track:@"Tapped Publish Story"
                                 properties:@{@"view": @"MRSLCreateMorselViewController",
                                              @"post_id": NSNullIfNil(_post.postID),
                                              @"post_draft":(_post.draftValue) ? @"true" : @"false"}];

    _post.draft = @NO;

    [_appDelegate.morselApiService updatePost:_post
                                      success:^(id responseObject) {
                                          self.lastUpdatedLabel.text = [NSString stringWithFormat:@"Last %@ %@", (_post.draftValue) ? @"saved" : @"updated", (_post.lastUpdatedDate) ? [[_post.lastUpdatedDate timeAgo] lowercaseString] : @"now"];
                                          [self.navigationItem setRightBarButtonItem:nil];
                                          [[NSNotificationCenter defaultCenter] postNotificationName:MRSLAppShouldDisplayFeedNotification
                                                                                              object:nil];
                                      } failure:^(NSError *error) {
                                          [UIAlertView showAlertViewForErrorString:@"Unable to publish Story, please try again!"
                                                                          delegate:nil];
                                      }];
}

#pragma mark - UITableViewDataSource Methods

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return (indexPath.row + 1 != [_morsels count] + 1);
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return (indexPath.row + 1 != [_morsels count] + 1);
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return (indexPath.row + 1 == [_morsels count] + 1);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ([_morsels count] + ((_shouldShowAddCell) ? 1 : 0));
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        MRSLMorsel *deletedMorsel = [_morsels objectAtIndex:indexPath.row];
        [_morsels removeObject:deletedMorsel];
        [_storyMorselsTableView deleteRowsAtIndexPaths:@[indexPath]
                                      withRowAnimation:UITableViewRowAnimationFade];

        __weak __typeof(self) weakSelf = self;

        double delayInSeconds = .4f;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            if (deletedMorsel.localUUID) {
                [[NSNotificationCenter defaultCenter] postNotificationName:MRSLUserDidDeleteMorselNotification
                                                                    object:deletedMorsel.morselID];
                [deletedMorsel MR_deleteEntity];
                [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfAndWait];
            } else {
                [_appDelegate.morselApiService deleteMorsel:deletedMorsel
                                                    success:^(BOOL success) {
                                                        if (weakSelf) {
                                                            [weakSelf updateStoryStatus];
                                                        }
                                                    } failure:nil];
            }
        });
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    MRSLMorsel *movedMorsel = [_morsels objectAtIndex:sourceIndexPath.row];
    [_morsels removeObject:movedMorsel];
    [_morsels insertObject:movedMorsel
                   atIndex:destinationIndexPath.row];

    __weak __typeof(self) weakSelf = self;

    [_morsels enumerateObjectsUsingBlock:^(MRSLMorsel *morsel, NSUInteger idx, BOOL *stop) {
        DDLogDebug(@"Morsel Previous Sort Order: %@", morsel.sort_order);
        morsel.sort_order = @(idx + 1);
        DDLogDebug(@"Morsel New Sort Order: %@", morsel.sort_order);
        [_appDelegate.morselApiService updateMorsel:morsel
                                            andPost:nil
                                            success:^(id responseObject) {
                                                if (weakSelf) {
                                                    [weakSelf updateStoryStatus];
                                                }
                                            } failure:nil];
    }];
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
    if (proposedDestinationIndexPath.row + 1 > [_morsels count]) {
        return sourceIndexPath;
    }
    return proposedDestinationIndexPath;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row + 1 > [_morsels count]) {
        UITableViewCell *addCell = [self.storyMorselsTableView dequeueReusableCellWithIdentifier:@"ruid_MorselAddCell"
                                                                                    forIndexPath:indexPath];
        return addCell;
    }
    MRSLMorsel *morsel = [_morsels objectAtIndex:indexPath.row];

    MRSLStoryEditMorselTableViewCell *storyMorselCell = [self.storyMorselsTableView dequeueReusableCellWithIdentifier:@"ruid_StoryMorselCell"
                                                                                                         forIndexPath:indexPath];
    storyMorselCell.morsel = morsel;
    storyMorselCell.delegate = self;
    return storyMorselCell;
}

#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    if (![selectedCell isKindOfClass:[MRSLStoryEditMorselTableViewCell class]]) {
        [self presentMediaCapture];
    }
}

#pragma mark - NSFetchedResultsControllerDelegate Methods

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    DDLogDebug(@"Feed detected content change. Reloading with %lu items.", (unsigned long)[[controller fetchedObjects] count]);
    [self populateContent];
}

#pragma mark - CaptureMediaViewControllerDelegate

- (void)captureMediaViewControllerDidFinishCapturingMediaItems:(NSMutableArray *)capturedMedia {
    DDLogDebug(@"Received %lu Media Items. Should now create Morsels for each!", (unsigned long)[capturedMedia count]);
    self.post = [self getOrLoadPostIfExists];
    __weak __typeof(self) weakSelf = self;
    [capturedMedia enumerateObjectsUsingBlock:^(MRSLMediaItem *mediaItem, NSUInteger idx, BOOL *stop) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            NSUInteger morselIndex = (idx + 1);
            if ([strongSelf.morsels count] > 0) {
                MRSLMorsel *lastMorsel = [strongSelf.morsels lastObject];
                morselIndex = (lastMorsel.sort_orderValue + (idx + 1));
            }
            DDLogDebug(@"Morsel INDEX: %lu", (unsigned long)morselIndex);
            MRSLMorsel *morsel = [MRSLMorsel localUniqueMorsel];
            morsel.post = strongSelf.post;
            morsel.isUploading = @YES;
            morsel.sort_order = @(morselIndex);

            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                morsel.morselPhoto = UIImageJPEGRepresentation(mediaItem.mediaFullImage, 1.f);
                morsel.morselPhotoCropped = UIImageJPEGRepresentation(mediaItem.mediaCroppedImage, 1.f);
                morsel.morselPhotoThumb = UIImageJPEGRepresentation(mediaItem.mediaThumbImage, .8f);
                if (morsel.managedObjectContext) {
                    [strongSelf.post addMorselsObject:morsel];
                    [_appDelegate.morselApiService createMorsel:morsel
                                                        success:^(id responseObject) {
                                                            if (weakSelf) {
                                                                [weakSelf updateStoryStatus];
                                                            }
                                                        } failure:nil];
                }
            });
        }
    }];
}

#pragma mark - MRSLStoryEditMorselCollectionViewCellDelegate

- (void)morselCollectionViewDidSelectEditText:(MRSLMorsel *)morsel {
    self.morsel = morsel;
    [self performSegueWithIdentifier:@"seg_EditMorselText"
                              sender:nil];
}

- (void)morselCollectionViewDidSelectImagePreview:(MRSLMorsel *)morsel {
    NSUInteger index = [_morsels indexOfObject:morsel];

    MRSLImagePreviewViewController *imagePreviewVC = [[UIStoryboard mediaManagementStoryboard] instantiateViewControllerWithIdentifier:@"sb_MRSLImagePreviewViewController"];
    [imagePreviewVC setPreviewMedia:_morsels andStartingIndex:index];

    [self presentViewController:imagePreviewVC
                       animated:YES
                     completion:nil];
}

@end
