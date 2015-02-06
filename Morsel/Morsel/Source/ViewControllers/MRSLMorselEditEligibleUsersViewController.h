//
//  MRSLMorselEditEligibleUsersViewController.h
//  Morsel
//
//  Created by Javier Otero on 10/6/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLBaseRemoteDataSourceViewController.h"

@class MRSLMorselEditEligibleUsersViewController;

@protocol MRSLMorselEditEligibleUsersViewControllerDelegate<NSObject>

@optional
- (void)morselEditEligibleUsersViewController:(MRSLMorselEditEligibleUsersViewController *)morselEditEligibleUsersViewController
         viewWillDisappearWithTaggedUserCount:(NSInteger)taggedUserCount;

@end

@interface MRSLMorselEditEligibleUsersViewController : MRSLBaseRemoteDataSourceViewController

@property (weak, nonatomic) id <MRSLMorselEditEligibleUsersViewControllerDelegate> delegate;

@property (weak, nonatomic) MRSLMorsel *morsel;

@end
