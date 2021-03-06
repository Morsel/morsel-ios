//
//  MRSLProfessionalSettingsTableViewController.m
//  Morsel
//
//  Created by Marty Trzpit on 6/24/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLProfessionalSettingsTableViewController.h"

#import "MRSLSectionView.h"
#import "MRSLToggleKeywordsTableViewController.h"

@interface MRSLProfessionalSettingsTableViewController ()

@end

@implementation MRSLProfessionalSettingsTableViewController

- (void)viewWillAppear:(BOOL)animated {
    //  Remove the 'Access it later from Settings' label
    if ([self presentingViewController] == nil) {
        [self.tableView setTableFooterView:nil];
    }
    [super viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:MRSLAppShouldDisplayOnboardingNotification object:nil];
    });
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController respondsToSelector:@selector(setKeywordType:)]) {
        if ([[segue identifier] isEqualToString:MRSLStoryboardSegueCuisinesKey])
            [segue.destinationViewController setKeywordType:@"Cuisines"];
        else if ([[segue identifier] isEqualToString:MRSLStoryboardSegueSpecialtiesKey])
            [segue.destinationViewController setKeywordType:@"Specialties"];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [MRSLSectionView sectionViewWithTitle:[self tableView:tableView titleForHeaderInSection:section]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return [self.tableView hasHeaderForSection:section] ? MRSLSectionViewDefaultHeight : 0.0f;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell setBackgroundColor:[UIColor morselDefaultCellBackgroundColor]];

    if (indexPath.section == 0 && indexPath.row == 0) {
        [cell addDefaultBorderForDirections:MRSLBorderNorth];
    } else if (![self.tableView isLastRowForIndexPath:indexPath]) {
        [cell addDefaultBorderForDirections:MRSLBorderSouth];
    }
}

@end
