//
//  KIFUITestActor+Additions.h
//  Morsel
//
//  Created by Javier Otero on 2/28/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "KIFUITestActor.h"

@interface KIFUITestActor (Additions)

- (void)navigateToLoginPage;
- (void)performLogIn;
- (void)returnToLoggedOutHomeScreen;

- (void)tapCellInCollectionViewWithAccessibilityLabel:(NSString*)tableViewLabel
                                          atIndexPath:(NSIndexPath *)indexPath;
@end
