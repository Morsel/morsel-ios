//
//  MRSLPushNotificationSettingsViewController.m
//  Morsel
//
//  Created by Javier Otero on 11/10/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLPushNotificationSettingsViewController.h"

#import "MRSLSectionView.h"
#import "MRSLSwitchTableViewCell.h"
#import "MRSLTableViewDataSource.h"

#import "MRSLRemoteDevice.h"

@interface MRSLBaseTableViewController ()

@property (strong, nonatomic) MRSLTableViewDataSource *dataSource;

@end

@interface MRSLPushNotificationSettingsViewController ()

@property (nonatomic) BOOL enableForComments;
@property (nonatomic) BOOL enableForLikes;
@property (nonatomic) BOOL enableForMorselUserTags;
@property (nonatomic) BOOL enableForFollows;
@property (nonatomic) BOOL enableForFollowupComments;

@property (weak, nonatomic) MRSLRemoteDevice *currentRemoteDevice;

@property (strong, nonatomic) NSArray *notificationSettingsArray;

@property (weak, nonatomic) IBOutlet UILabel *emptyStateTitleView;

@end

@implementation MRSLPushNotificationSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.disableFetchRefresh = YES;
    self.currentRemoteDevice = [MRSLRemoteDevice currentRemoteDevice];

    if (self.currentRemoteDevice) {
        self.enableForComments = self.currentRemoteDevice.notify_item_commentValue;
        self.enableForLikes = self.currentRemoteDevice.notify_morsel_likeValue;
        self.enableForMorselUserTags = self.currentRemoteDevice.notify_morsel_morsel_user_tagValue;
        self.enableForFollows = self.currentRemoteDevice.notify_user_followValue;
        self.enableForFollowupComments = self.currentRemoteDevice.notify_tagged_morsel_item_commentValue;
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:MRSLRegisterRemoteNotificationsNotification
                                                            object:nil];
    }

    [self updateContent];
    self.dataSource = [[MRSLTableViewDataSource alloc] initWithObjects:self.notificationSettingsArray
                                                    configureCellBlock:^UITableViewCell *(NSDictionary *notificationSettingDictionary, UITableView *tableView, NSIndexPath *indexPath, NSUInteger count) {
                                                        MRSLSwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MRSLStoryboardRUIDPushNotificationSettingCellKey];
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            [cell.cellLabel setText:notificationSettingDictionary[@"name"]];
                                                            [cell.cellSwitch setOn:[notificationSettingDictionary[@"value"] boolValue]
                                                                          animated:YES];
                                                        });
                                                        return cell;
                                                    }];
    self.tableView.alwaysBounceVertical = ([self.notificationSettingsArray count] > 0);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.emptyStateTitleView.hidden = ([self.notificationSettingsArray count] > 0);
    if (!self.emptyStateTitleView.hidden) {
        [self.emptyStateTitleView setHeight:[self.view getHeight] - MRSLAppStatusAndNavigationBarHeight];
    }
}

#pragma mark - Private Methods

- (BOOL)isDirty {
    if (!self.currentRemoteDevice) return NO;
    return (self.currentRemoteDevice.notify_item_commentValue != self.enableForComments ||
            self.currentRemoteDevice.notify_morsel_likeValue != self.enableForLikes ||
            self.currentRemoteDevice.notify_morsel_morsel_user_tagValue != self.enableForMorselUserTags ||
            self.currentRemoteDevice.notify_user_followValue != self.enableForFollows);
}

- (void)goBack {
    if ([self isDirty]) {
        [UIAlertView showAlertViewWithTitle:@"Warning"
                                    message:@"You have unsaved changes, are you sure you want to discard them?"
                                   delegate:self
                          cancelButtonTitle:@"Cancel"
                          otherButtonTitles:@"Discard", nil];
    } else {
        [super goBack];
    }
}

- (IBAction)saveChanges:(id)sender {
    [sender setEnabled:NO];

    self.currentRemoteDevice = [MRSLRemoteDevice currentRemoteDevice];

    __weak __typeof(self) weakSelf = self;
    __weak __typeof(sender) weakSender = sender;

    self.currentRemoteDevice.notify_item_comment = @(self.enableForComments);
    self.currentRemoteDevice.notify_morsel_like = @(self.enableForLikes);
    self.currentRemoteDevice.notify_morsel_morsel_user_tag = @(self.enableForMorselUserTags);
    self.currentRemoteDevice.notify_user_follow = @(self.enableForFollows);
    self.currentRemoteDevice.notify_tagged_morsel_item_comment = @(self.enableForFollowupComments);

    [self.currentRemoteDevice API_updateWithSuccess:^(id responseObject) {
        if (weakSelf.currentRemoteDevice.managedObjectContext) [weakSelf.currentRemoteDevice.managedObjectContext MR_saveOnlySelfAndWait];
        [UIAlertView showAlertViewWithTitle:@"Success!"
                                    message:@"Your notification preferences have been updated."
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
        [weakSender setEnabled:YES];
        [super goBack];
    } failure:^(NSError *error) {
        DDLogError(@"Error updating notification preferences");
        [UIAlertView showOKAlertViewWithTitle:@"Unable to update notification preferences"
                                      message:@"A network error occurred. Please try again."];
        [weakSender setEnabled:YES];
    }];
}

- (void)updateContent {
    self.currentRemoteDevice = [MRSLRemoteDevice currentRemoteDevice];

    self.notificationSettingsArray = (self.currentRemoteDevice) ? @[@{@"name": @"Comments on my morsel",
                                                                      @"value": @(_enableForComments)},
                                                                    @{@"name": @"Comments on a morsel I'm tagged in",
                                                                      @"value": @(_enableForFollowupComments)},
                                                                    @{@"name": @"Likes one of my morsels",
                                                                      @"value": @(_enableForLikes)},
                                                                    @{@"name": @"Tags me in a morsel",
                                                                      @"value": @(_enableForMorselUserTags)},
                                                                    @{@"name": @"Starts following me",
                                                                      @"value": @(_enableForFollows)}] : [NSArray array];
    if (self.dataSource ) {
        [self.dataSource updateObjects:self.notificationSettingsArray];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }

    [[self.navigationItem rightBarButtonItem] setEnabled:[self isDirty]];
}

#pragma mark - UITableViewDataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return (section == 0 && [self.notificationSettingsArray count] > 0) ? @"Notify me when someone" : nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [MRSLSectionView sectionViewWithTitle:[self tableView:tableView titleForHeaderInSection:section]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return [self.tableView hasHeaderForSection:section] ? MRSLSectionViewDefaultHeight : 0.f;
}

#pragma mark - MRSLTableViewDataSourceDelegate

- (CGFloat)tableViewDataSource:(UITableView *)tableView heightForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *notificationSettingName = [self.notificationSettingsArray objectAtIndex:indexPath.row][@"name"];

    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    CGRect bodyRect = [notificationSettingName boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 80.f, CGFLOAT_MAX)
                                                            options:NSStringDrawingUsesLineFragmentOrigin
                                                         attributes:@{NSFontAttributeName: [UIFont robotoLightFontOfSize:14.f], NSParagraphStyleAttributeName: paragraphStyle}
                                                            context:nil];
    return MAX(44.f, bodyRect.size.height);
}

- (void)tableViewDataSource:(UITableView *)tableView
   didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
            self.enableForComments = !self.enableForComments;
            break;
        case 1:
            self.enableForLikes = !self.enableForLikes;
            break;
        case 2:
            self.enableForMorselUserTags = !self.enableForMorselUserTags;
            break;
        case 3:
            self.enableForFollows = !self.enableForFollows;
            break;
        default:
            break;
    }
    [self updateContent];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Discard"]) {
        [super goBack];
    }
}

@end
