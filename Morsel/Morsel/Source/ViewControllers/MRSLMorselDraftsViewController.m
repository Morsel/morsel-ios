//
//  MRSLMorselListViewController.m
//  Morsel
//
//  Created by Javier Otero on 3/3/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLMorselDraftsViewController.h"

#import "MRSLAPIService+Morsel.h"
#import "MRSLAPIService+Templates.h"

#import "MRSLMorselTableViewCell.h"
#import "MRSLMorselEditViewController.h"
#import "MRSLTableView.h"
#import "MRSLTableViewDataSource.h"

#import "MRSLItem.h"
#import "MRSLMorsel.h"
#import "MRSLUser.h"
#import "MRSLTemplate.h"

@interface MRSLMorselDraftsViewController ()
<MRSLTableViewDataSourceDelegate>

@property (strong, nonatomic) NSIndexPath *selectedIndexPath;

@end

@implementation MRSLMorselDraftsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.allowObserversToRemain = YES;
    self.mp_eventView = @"drafts";
    self.title = @"Drafts";

    [self.tableView setEmptyStateTitle:@"None yet. Create a new morsel below."];

    MRSLTemplate *morselTemplate = [MRSLTemplate MR_findFirst];
    if (!morselTemplate) [_appDelegate.apiService getTemplatesWithSuccess:nil
                                                                  failure:nil];

    self.pagedRemoteRequestBlock = ^(NSNumber *page, NSNumber *count, MRSLRemoteRequestWithObjectIDsOrErrorCompletionBlock remoteRequestWithObjectIDsOrErrorCompletionBlock) {
        [_appDelegate.apiService getMorselsForUser:nil
                                              page:page
                                             count:nil
                                        onlyDrafts:YES
                                           success:^(NSArray *responseArray) {
                                               remoteRequestWithObjectIDsOrErrorCompletionBlock(responseArray, nil);
                                           } failure:^(NSError *error) {
                                               remoteRequestWithObjectIDsOrErrorCompletionBlock(nil, error);
                                           }];
    };

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(morselCreated)
                                                 name:MRSLUserDidCreateMorselNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(morselDeleted:)
                                                 name:MRSLUserDidDeleteMorselNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_selectedIndexPath) {
        [self.tableView deselectRowAtIndexPath:_selectedIndexPath
                                      animated:YES];
        self.selectedIndexPath = nil;
        [self refreshLocalContent];
    }
}

- (NSString *)objectIDsKey {
    return @"currentuser_morsel_drafts";
}

- (NSFetchedResultsController *)defaultFetchedResultsController {
    return  [MRSLMorsel MR_fetchAllSortedBy:@"lastUpdatedDate"
                                  ascending:NO
                              withPredicate:[NSPredicate predicateWithFormat:@"morselID IN %@", self.objectIDs]
                                    groupBy:nil
                                   delegate:self
                                  inContext:[NSManagedObjectContext MR_defaultContext]];
}

- (MRSLDataSource *)dataSource {
    MRSLDataSource *superDataSource = [super dataSource];
    if (superDataSource) return superDataSource;
    MRSLDataSource *newDataSource = [[MRSLTableViewDataSource alloc] initWithObjects:nil
                                                                  configureCellBlock:^UITableViewCell *(id item, UITableView *tableView, NSIndexPath *indexPath, NSUInteger count) {
                                                                      MRSLMorsel *morsel = item;
                                                                      MRSLMorselTableViewCell *morselCell = [self.tableView dequeueReusableCellWithIdentifier:MRSLStoryboardRUIDMorselCellKey];
                                                                      morselCell.morsel = morsel;
                                                                      morselCell.morselPipeView.hidden = (indexPath.row == count - 1);
                                                                      return morselCell;
                                                                  }];
    [self setDataSource:newDataSource];
    return newDataSource;
}

#pragma mark - Notification Methods

- (void)morselCreated {
    [self refreshRemoteContent];
}

- (void)morselDeleted:(NSNotification *)notification {
    [self refreshLocalContent];
}

#pragma mark - MRSLTableViewDataSource Methods

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        MRSLMorsel *deletedMorsel = [self.dataSource objectAtIndexPath:indexPath];
        [[MRSLEventManager sharedManager] track:@"Tapped Button"
                                     properties:@{@"_title": @"Delete Morsel",
                                                  @"_view": self.mp_eventView,
                                                  @"item_count": @([self.dataSource count]),
                                                  @"morsel_id": NSNullIfNil(deletedMorsel.morselID)}];
        [self.dataSource removeObject:deletedMorsel];
        [tableView deleteRowsAtIndexPaths:@[indexPath]
                         withRowAnimation:UITableViewRowAnimationFade];
        double delayInSeconds = .4f;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [_appDelegate.apiService deleteMorsel:deletedMorsel
                                          success:nil
                                          failure:nil];
        });
    }
}

- (void)tableViewDataSource:(UITableView *)tableView
              didSelectItem:(id)item
                atIndexPath:(NSIndexPath *)indexPath {
    self.selectedIndexPath = indexPath;
    MRSLMorsel *morsel = item;
    [[MRSLEventManager sharedManager] track:@"Tapped Button"
                                 properties:@{@"_title": @"Morsel",
                                              @"_view": self.mp_eventView,
                                              @"morsel_id": NSNullIfNil(morsel.morselID),
                                              @"morsel_draft": (morsel.draftValue) ? @"true" : @"false"}];
    MRSLMorselEditViewController *editMorselVC = [[UIStoryboard morselManagementStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardMorselEditViewControllerKey];
    editMorselVC.morselID = morsel.morselID;

    [self.navigationController pushViewController:editMorselVC
                                         animated:YES];
}

- (CGFloat)tableViewDataSource:(UITableView *)tableView heightForItemAtIndexPath:(NSIndexPath *)indexPath {
    return 60.f;
}

@end
