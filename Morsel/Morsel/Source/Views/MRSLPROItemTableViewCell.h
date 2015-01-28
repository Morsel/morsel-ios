//
//  MRSLPROItemTableViewCell.h
//  Morsel
//
//  Created by Marty Trzpit on 1/28/15.
//  Copyright (c) 2015 Morsel. All rights reserved.
//

#import "MRSLPROExpandableTextTableViewCell.h"

@interface MRSLPROItemTableViewCell : MRSLPROExpandableTextTableViewCell <UIActionSheetDelegate>

- (void)shouldHideEverythingButImage:(BOOL)shouldHideEverythingButImage;

@end
