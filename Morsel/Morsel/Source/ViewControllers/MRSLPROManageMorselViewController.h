//
//  MRSLPROManageMorselViewController.h
//  Morsel
//
//  Created by Marty Trzpit on 1/27/15.
//  Copyright (c) 2015 Morsel. All rights reserved.
//

#import "MRSLBaseViewController.h"

#import "MRSLPROInputAccessoryToolbar.h"
#import "MRSLPROTitleTextViewTableViewCell.h"

@interface MRSLPROManageMorselViewController : MRSLBaseViewController <MRSLPROExpandableTextTableViewCellDelegate, MRSLPROInputAccessoryToolbarDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSNumber *morselID;

@end
