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

#pragma mark - Login Flow

- (void)navigateToLoginPage {
    [self tapViewWithAccessibilityLabel:@"Log in"];
}

- (void)performLogIn {
    [self waitForViewWithAccessibilityLabel:@"Log in"];
    [self enterText:@"javierotero" intoViewWithAccessibilityLabel:@"Username or email"];
    [self enterText:@"morselios" intoViewWithAccessibilityLabel:@"Password"];
    [self waitAndTapViewWithAccessibilityLabel:@"Log in"];
    [self waitAndTapViewWithAccessibilityLabel:@"How to use Morsel"];
}

- (void)returnToLoggedOutHomeScreen {
    [self waitAndTapViewWithAccessibilityLabel:@"Menu"];
    [self waitAndTapViewWithAccessibilityLabel:@"Settings"];
    [self waitAndTapViewWithAccessibilityLabel:@"Log Out"];
    [self waitAndTapViewWithAccessibilityLabel:@"Yes"];
    [self waitForViewWithAccessibilityLabel:@"Log in"];
}

#pragma mark - Profile Flow

- (void)navigateToCurrentUserProfile {
    [self waitAndTapViewWithAccessibilityLabel:@"Menu"];
    [self waitAndTapViewWithAccessibilityLabel:@"View profile"];
    [self waitForViewWithAccessibilityLabel:@"javierotero"];
}

#pragma mark - Collection Flow



#pragma mark - Utilties

- (void)waitAndTapViewWithAccessibilityLabel:(NSString *)label {
    [self waitForViewWithAccessibilityLabel:label];
    [self tapViewWithAccessibilityLabel:label];
}

@end
