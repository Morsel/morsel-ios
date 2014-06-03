//
//  MRSLProfileStatsKeywordsViewController.h
//  Morsel
//
//  Created by Javier Otero on 4/28/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MRSLProfileUserTagsListViewControllerDelegate <NSObject>

@optional
- (void)profileUserTagsListViewControllerDidSelectTag:(MRSLTag *)tag;
- (void)profileUserTagsListViewControllerDidSelectType:(NSString *)type;

@end

@interface MRSLProfileUserTagsListViewController : UIViewController

@property (nonatomic) BOOL allowsEdit;

@property (weak, nonatomic) id <MRSLProfileUserTagsListViewControllerDelegate> delegate;

@property (weak, nonatomic) MRSLUser *user;

@end