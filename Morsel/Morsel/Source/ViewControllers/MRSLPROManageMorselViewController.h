//
//  MRSLPROManageMorselViewController.h
//  Morsel
//
//  Created by Marty Trzpit on 1/27/15.
//  Copyright (c) 2015 Morsel. All rights reserved.
//

#import "MRSLBaseViewController.h"

#import <ELCImagePickerController/ELCImagePickerController.h>
#import "MRSLMorselPublishShareViewController.h"

#import "MRSLPROInputAccessoryToolbar.h"
#import "MRSLPROTitleTextViewTableViewCell.h"

@interface MRSLPROManageMorselViewController : MRSLBaseViewController <ELCImagePickerControllerDelegate, UIImagePickerControllerDelegate, MRSLMorselPublishShareViewControllerDelegate, MRSLPROExpandableTextTableViewCellDelegate, MRSLPROInputAccessoryToolbarDelegate, UIActionSheetDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSNumber *morselID;

@end
