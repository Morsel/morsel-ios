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
    [self waitForViewWithAccessibilityLabel:@"Sign up"];
    [self tapViewWithAccessibilityLabel:@"Already have an account? Sign in!"];
}

- (void)performLogIn {
    [self waitForViewWithAccessibilityLabel:@"Login"];
    [self enterText:@"javier@eatmorsel.com" intoViewWithAccessibilityLabel:@"Email"];
    [self enterText:@"morselios" intoViewWithAccessibilityLabel:@"Password"];
    [self tapViewWithAccessibilityLabel:@"Log in"];
}

- (void)returnToLoggedOutHomeScreen {
    [self tapViewWithAccessibilityLabel:@"Menu"];
    [self waitForViewWithAccessibilityLabel:@"Logout"];
    [self tapViewWithAccessibilityLabel:@"Logout"];
    [self waitForViewWithAccessibilityLabel:@"Sign up"];
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
            [self failWithError:[NSError KIFErrorWithFormat:@"Section %d is not found in '%@' collection view", indexPath.section, collectionViewLabel] stopTest:YES];
        }

        if (indexPath.row >= [collectionView numberOfItemsInSection:indexPath.section]) {
            [self failWithError:[NSError KIFErrorWithFormat:@"Row %d is not found in section %d of '%@' collection view", indexPath.row, indexPath.section, collectionViewLabel] stopTest:YES];
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
