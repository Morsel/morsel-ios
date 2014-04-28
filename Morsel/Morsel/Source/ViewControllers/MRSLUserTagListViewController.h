//
//  MRSLTagUserListViewController.h
//  Morsel
//
//  Created by Javier Otero on 4/29/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MRSLUserTagListViewController : MRSLBaseViewController

@property (weak, nonatomic) MRSLUser *user;

@property (strong, nonatomic) NSString *keywordType;

@end
