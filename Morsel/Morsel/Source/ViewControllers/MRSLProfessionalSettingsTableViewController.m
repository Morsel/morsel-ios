//
//  MRSLProfessionalSettingsTableViewController.m
//  Morsel
//
//  Created by Marty Trzpit on 6/24/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLProfessionalSettingsTableViewController.h"

#import "MRSLToggleKeywordsTableViewController.h"

@interface MRSLProfessionalSettingsTableViewController ()

@end

@implementation MRSLProfessionalSettingsTableViewController

- (void)viewWillAppear:(BOOL)animated {
    //  Remove the 'Access it later from Settings' label
    if ([self presentingViewController] == nil) {
        [self.tableView setTableHeaderView:nil];
    }
    [super viewWillAppear:animated];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController respondsToSelector:@selector(setKeywordType:)]) {
        if ([[segue identifier] isEqualToString:@"seg_Cuisines"])
            [segue.destinationViewController setKeywordType:@"Cuisines"];
        else if ([[segue identifier] isEqualToString:@"seg_Specialties"])
            [segue.destinationViewController setKeywordType:@"Specialties"];
    }
}

@end
