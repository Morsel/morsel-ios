//
//  KIFUITestActor+Additions.m
//  Morsel
//
//  Created by Javier Otero on 2/28/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "KIFUITestActor+Additions.h"

#import "CGGeometry-KIFAdditions.h"
#import "NSError-KIFAdditions.h"

@implementation KIFUITestActor (Additions)

- (void)navigateToLoginPage {
    [self tapViewWithAccessibilityLabel:@"Log in"];
}

- (void)performLogIn {
    [self waitForViewWithAccessibilityLabel:@"Log in"];
    [self enterText:@"javierotero" intoViewWithAccessibilityLabel:@"Username or email"];
    [self enterText:@"morselios" intoViewWithAccessibilityLabel:@"Password"];
    [self tapViewWithAccessibilityLabel:@"go"];
}

- (void)returnToLoggedOutHomeScreen {
    [self tapViewWithAccessibilityLabel:@"Menu"];
    [self tapViewWithAccessibilityLabel:@"Settings"];
    [self tapViewWithAccessibilityLabel:@"Log Out"];
    [self waitForViewWithAccessibilityLabel:@"Yes"];
    [self tapViewWithAccessibilityLabel:@"Yes"];
    [self waitForViewWithAccessibilityLabel:@"Log in"];
}

#warning Figure out why collectionview is casting as tableview

- (void)tapCellInCollectionViewWithAccessibilityLabel:(NSString*)collectionViewLabel
                                          atIndexPath:(NSIndexPath *)indexPath {
    UICollectionView *collectionView = (UICollectionView *)[self waitForViewWithAccessibilityLabel:collectionViewLabel];

    if (![collectionView isKindOfClass:[UICollectionView class]]) {
        [self failWithError:[NSError KIFErrorWithFormat:@"View is not a collection view"]
                   stopTest:YES];
    }

    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];

    // If section < 0, search from the end of the table.
    if (indexPath.section < 0) {
        indexPath = [NSIndexPath indexPathForRow:indexPath.row
                                       inSection:collectionView.numberOfSections + indexPath.section];
    }

    // If row < 0, search from the end of the section.
    if (indexPath.row < 0) {
        indexPath = [NSIndexPath indexPathForRow:[collectionView numberOfItemsInSection:indexPath.section] + indexPath.row
                                       inSection:indexPath.section];
    }

    if (!cell) {
        if (indexPath.section >= collectionView.numberOfSections) {
            [self failWithError:[NSError KIFErrorWithFormat:@"Section %ld is not found in '%@' collection view", (long)indexPath.section, collectionViewLabel] stopTest:YES];
        }

        if (indexPath.row >= [collectionView numberOfItemsInSection:indexPath.section]) {
            [self failWithError:[NSError KIFErrorWithFormat:@"Row %ld is not found in section %ld of '%@' collection view", (long)indexPath.row, (long)indexPath.section, collectionViewLabel] stopTest:YES];
        }

        [collectionView scrollToItemAtIndexPath:indexPath
                               atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                       animated:YES];
        [self waitForTimeInterval:0.5];
        cell = [collectionView cellForItemAtIndexPath:indexPath];
    }

    if (!cell) {
        [self failWithError:[NSError KIFErrorWithFormat: @"Collection view cell at index path %@ not found", indexPath] stopTest:YES];
    }

    CGRect cellFrame = [cell.contentView convertRect:cell.contentView.frame
                                              toView:collectionView];
    [collectionView tapAtPoint:CGPointCenteredInRect(cellFrame)];
}

@end
