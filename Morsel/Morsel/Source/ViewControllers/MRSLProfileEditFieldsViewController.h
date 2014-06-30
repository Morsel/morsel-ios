//
//  MRSLProfileEditFieldsViewController.h
//  Morsel
//
//  Created by Javier Otero on 5/28/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLBaseViewController.h"

@interface MRSLProfileEditFieldsViewController : MRSLBaseViewController

@property (weak, nonatomic) MRSLUser *user;
@property (weak, nonatomic) UIView *containingView;

- (void)updateProfileWithCompletion:(MRSLSuccessBlock)didUpdateOrNil
                            failure:(MRSLFailureBlock)failure;

@end
