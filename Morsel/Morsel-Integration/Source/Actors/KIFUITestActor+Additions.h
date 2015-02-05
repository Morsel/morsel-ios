//
//  KIFUITestActor+Additions.h
//  Morsel
//
//  Created by Javier Otero on 2/28/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "KIFUITestActor.h"

@interface KIFUITestActor (Additions)

#pragma mark - Login Flow

- (void)navigateToLoginPage;
- (void)performLogIn;
- (void)returnToLoggedOutHomeScreen;

#pragma mark - Profile Flow

- (void)navigateToCurrentUserProfile;

#pragma mark - Collection Flow

#pragma mark - Utilities

- (void)waitAndTapViewWithAccessibilityLabel:(NSString *)label;

@end
