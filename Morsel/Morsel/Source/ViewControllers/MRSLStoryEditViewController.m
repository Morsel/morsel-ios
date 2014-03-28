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

@property (weak, nonatomic) IBOutlet UIButton *storyTitleButton;
@property (weak, nonatomic) IBOutlet UILabel *storyTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastUpdatedLabel;
@property (weak, nonatomic) IBOutlet UITableView *storyMorselsTableView;

@property (strong, nonatomic) UIBarButtonItem *publishButton;
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
    [_statusDateFormatter setDateFormat:@"MMM dd, h:mm a"];

    [self displayStory];
    [self updateStoryStatus];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self displayStory];

    if (_shouldPresentMediaCapture) {
        self.wasNewStory = YES;
        [self presentMediaCapture];
    }
}

- (void)displayStory {
    [self getOrLoadPostIfExists];

    if (_post.draftValue) {
        self.publishButton = [[UIBarButtonItem alloc] initWithTitle:@"Publish"
                                                              style:UIBarButtonItemStyleBordered
                                                             target:self
                                                             action:@selector(publishStory)];
        [self.navigationItem setRightBarButtonItem:_publishButton];
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
    self.lastUpdatedLabel.text = [NSString stringWithFormat:@"Last saved at %@", (lastUpdated) ? [_statusDateFormatter stringFromDate:lastUpdated] : [_statusDateFormatter stringFromDate:[NSDate date]]];
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
    if (_storyMorselsTableView.isEditing) [_storyMorselsTableView setEditing:NO animated:YES];
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
        [[MRSLEventManager sharedManager] track:@"Tapped Settings"
                                     properties:@{@"view": @"Your Story",
                                                  @"morsel_count": @([_morsels count]),
                                                  @"story_id": NSNullIfNil(_post.postID),
                                                  @"story_draft":(_post.draftValue) ? @"true" : @"false"}];
        MRSLStorySettingsViewController *storySettingsVC = [segue destinationViewController];
        storySettingsVC.post = _post;
    }
}

#pragma mark - Action Methods

- (IBAction)toggleEditing {
    [[MRSLEventManager sharedManager] track:@"Tapped Edit"
                                 properties:@{@"view": @"Your Story",
                                              @"story_id": NSNullIfNil(_post.postID)}];
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
                                 properties:@{@"view": @"Your Story",
                                              @"morsel_count": @([_morsels count]),
                                              @"story_id": NSNullIfNil(_post.postID),
                                              @"story_draft":(_post.draftValue) ? @"true" : @"false"}];

    _post.draft = @NO;
    _publishButton.enabled = NO;

    [_appDelegate.morselApiService updatePost:_post
                                      success:^(id responseObject) {
                                          self.lastUpdatedLabel.text = [NSString stringWithFormat:@"Last %@ %@", (_post.draftValue) ? @"saved" : @"updated", (_post.lastUpdatedDate) ? [[_post.lastUpdatedDate timeAgo] lowercaseString] : @"now"];
                                          [self.navigationItem setRightBarButtonItem:nil];
                                          [[NSNotificationCenter defaultCenter] postNotificationName:MRSLAppShouldDisplayFeedNotification
                                                                                              object:nil];
                                      } failure:^(NSError *error) {
                                          _publishButton.enabled = YES;
                                          [UIAlertView showAlertViewForErrorString:@"Unable to publish Story, please try again!"
                                                                          delegate:nil];
                                      }];
}

#pragma mark - UITableViewDataSource Methods

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return (indexPath.row + 1 != [_morsels count] + 1);
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return (indexPath.row + 1 != [_morsels count] + 1 && [_morsels count] > 1);
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
        [[MRSLEventManager sharedManager] track:@"Tapped Delete Morsel"
                                     properties:@{@"view": @"Your Story",
                                                  @"morsel_count": @([_morsels count]),
                                                  @"story_id": NSNullIfNil(_post.postID),
                                                  @"morsel_id": NSNullIfNil(deletedMorsel.morselID)}];
        [_morsels removeObject:deletedMorsel];
        [_storyMorselsTableView deleteRowsAtIndexPaths:@[indexPath]
                                      withRowAnimation:UITableViewRowAnimationFade];

        __weak __typeof(self) weakSelf = self;

        double delayInSeconds = .4f;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [_appDelegate.morselApiService deleteMorsel:deletedMorsel
                                                success:^(BOOL success) {
                                                    if (weakSelf) {
                                                        [weakSelf getOrLoadPostIfExists].lastUpdatedDate = [NSDate date];
                                                        [weakSelf displayStoryStatus];
                                                    }
                                                } failure:nil];
        });
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    MRSLMorsel *movedMorsel = [_morsels objectAtIndex:sourceIndexPath.row];
    MRSLMorsel *replacedMorsel = [_morsels objectAtIndex:destinationIndexPath.row];
    if ([replacedMorsel isEqual:movedMorsel]) return;
    [_morsels removeObject:movedMorsel];
    [_morsels insertObject:movedMorsel
                   atIndex:destinationIndexPath.row];

    [[MRSLEventManager sharedManager] track:@"Tapped Reordered Morsel"
                                 properties:@{@"view": @"Your Story",
                                              @"morsel_count": @([_morsels count]),
                                              @"story_id": NSNullIfNil(_post.postID),
                                              @"morsel_id": NSNullIfNil(movedMorsel.morselID)}];

    DDLogDebug(@"Morsel Previous Sort Order: %@", movedMorsel.sort_order);
    DDLogDebug(@"Morsel Replacing Sort Order: %@", replacedMorsel.sort_order);
    BOOL shouldPlaceAfter = (sourceIndexPath.row < destinationIndexPath.row);
    movedMorsel.sort_order = @((shouldPlaceAfter) ? replacedMorsel.sort_orderValue + 1 : replacedMorsel.sort_orderValue);

    for (NSInteger i = destinationIndexPath.row + 1; i < [_morsels count]; i++) {
        MRSLMorsel *nextMorsel = [_morsels objectAtIndex:i];
        nextMorsel.sort_order = @(nextMorsel.sort_orderValue + 1);
        DDLogDebug(@"Morsel SORT CHANGED: %@", nextMorsel.sort_order);
    }
    DDLogDebug(@"Morsel New Sort Order: %@", movedMorsel.sort_order);

    __weak __typeof(self) weakSelf = self;
    [_appDelegate.morselApiService updateMorsel:movedMorsel
                                        andPost:nil
                                        success:^(id responseObject) {
                                            if (weakSelf) {
                                                [weakSelf getOrLoadPostIfExists].lastUpdatedDate = [NSDate date];
                                                [weakSelf displayStoryStatus];
                                            }
                                        } failure:nil];
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
        [[MRSLEventManager sharedManager] track:@"Tapped Add New"
                                     properties:@{@"view": @"Your Story",
                                                  @"morsel_count": @([_morsels count])}];
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
    self.shouldPresentMediaCapture = NO;
    self.post = [self getOrLoadPostIfExists];
    NSArray *mediaToImport = [capturedMedia copy];
    __weak __typeof(self) weakSelf = self;
    DDLogDebug(@"Received %lu Media Items. Should now create Morsels for each!", (unsigned long)[capturedMedia count]);
    [mediaToImport enumerateObjectsUsingBlock:^(MRSLMediaItem *mediaItem, NSUInteger idx, BOOL *stop) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            NSUInteger morselIndex = (idx + 1);
            if ([strongSelf.morsels count] > 0) {
                MRSLMorsel *lastMorsel = [strongSelf.morsels lastObject];
                morselIndex = (lastMorsel.sort_orderValue + (idx + 1));
            }
            DDLogDebug(@"Morsel INDEX: %lu", (unsigned long)morselIndex);

            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                MRSLPost *post = [MRSLPost MR_findFirstByAttribute:MRSLPostAttributes.postID
                                                         withValue:strongSelf.post.postID];

                MRSLMorsel *morsel = [MRSLMorsel localUniqueMorsel];
                morsel.sort_order = @(morselIndex);
                morsel.morselPhotoCropped = UIImageJPEGRepresentation(mediaItem.mediaCroppedImage, 1.f);
                morsel.morselPhotoThumb = UIImageJPEGRepresentation(mediaItem.mediaThumbImage, .8f);
                morsel.isUploading = @YES;
                morsel.post = post;
                if (morsel.managedObjectContext && post.managedObjectContext) {
                    [post addMorselsObject:morsel];
                    [_appDelegate.morselApiService createMorsel:morsel
                                                        success:^(id responseObject) {
                                                            if (weakSelf) {
                                                                [weakSelf getOrLoadPostIfExists].lastUpdatedDate = [NSDate date];
                                                                [weakSelf displayStoryStatus];
                                                                [_appDelegate.morselApiService updateMorselImage:morsel
                                                                                                         success:nil
                                                                                                         failure:nil];
                                                            }
                                                        } failure:nil];
                }
            });
        }
    }];
}

- (void)captureMediaViewControllerDidCancel {
    if (_shouldPresentMediaCapture) [self goBack];
}

#pragma mark - MRSLStoryEditMorselCollectionViewCellDelegate

- (void)morselCollectionViewDidSelectEditText:(MRSLMorsel *)morsel {
    self.morsel = morsel;
    [[MRSLEventManager sharedManager] track:@"Tapped Add Description"
                                 properties:@{@"view": @"Your Story",
                                              @"morsel_count": @([_morsels count]),
                                              @"story_id": NSNullIfNil(_post.postID),
                                              @"morsel_id": NSNullIfNil(morsel.morselID)}];
    [self performSegueWithIdentifier:@"seg_EditMorselText"
                              sender:nil];
}

- (void)morselCollectionViewDidSelectImagePreview:(MRSLMorsel *)morsel {
    [[MRSLEventManager sharedManager] track:@"Tapped Thumbnail"
                                 properties:@{@"view": @"Your Story",
                                              @"morsel_count": @([_morsels count]),
                                              @"story_id": NSNullIfNil(_post.postID),
                                              @"morsel_id": NSNullIfNil(morsel.morselID)}];
    NSUInteger index = [_morsels indexOfObject:morsel];

    MRSLImagePreviewViewController *imagePreviewVC = [[UIStoryboard mediaManagementStoryboard] instantiateViewControllerWithIdentifier:@"sb_MRSLImagePreviewViewController"];
    [imagePreviewVC setPreviewMedia:_morsels andStartingIndex:index];

    [self presentViewController:imagePreviewVC
                       animated:YES
                     completion:nil];
}

@end
