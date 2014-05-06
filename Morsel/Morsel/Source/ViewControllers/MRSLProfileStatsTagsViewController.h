//
//  MRSLProfileStatsKeywordsViewController.h
//  Morsel
//
//  Created by Javier Otero on 4/28/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MRSLProfileStatsTagsViewControllerDelegate <NSObject>

@optional
- (void)profileStatsTagsViewControllerDidSelectTag:(MRSLTag *)tag;
- (void)profileStatsTagsViewControllerDidSelectType:(NSString *)type;

@end

@interface MRSLProfileStatsTagsViewController : UIViewController

@property (nonatomic) BOOL allowsEdit;

@property (weak, nonatomic) id <MRSLProfileStatsTagsViewControllerDelegate> delegate;

@property (weak, nonatomic) MRSLUser *user;

@end
