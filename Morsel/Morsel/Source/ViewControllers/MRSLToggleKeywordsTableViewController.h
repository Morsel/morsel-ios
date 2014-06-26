//
//  MRSLToggleKeywordsTableViewController.h
//  Morsel
//
//  Created by Marty Trzpit on 6/24/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLBaseTableViewController.h"

@interface MRSLToggleKeywordsTableViewController : MRSLBaseTableViewController

@property (weak, nonatomic) MRSLUser *user;
@property (strong, nonatomic) NSString *keywordType;

@end
