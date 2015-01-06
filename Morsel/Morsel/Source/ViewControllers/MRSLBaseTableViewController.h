//
//  MRSLBaseTableViewController.h
//  Morsel
//
//  Created by Marty Trzpit on 6/5/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "UIViewController+Base.h"

@interface MRSLBaseTableViewController : UITableViewController

@property (nonatomic) BOOL disableRemoteCapabilities;
@property (nonatomic) BOOL disablePagination;
@property (nonatomic) BOOL loadingMore;

@property (strong, nonatomic) NSIndexPath *selectedIndexPath;

@end
