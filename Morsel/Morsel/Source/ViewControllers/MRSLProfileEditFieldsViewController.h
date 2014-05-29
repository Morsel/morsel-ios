//
//  MRSLProfileEditFieldsViewController.h
//  Morsel
//
//  Created by Javier Otero on 5/28/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MRSLProfileEditFieldsViewController : UIViewController

@property (weak, nonatomic) UIView *containingView;

- (void)updateProfileWithCompletion:(MRSLSuccessBlock)didUpdateOrNil
                            failure:(MRSLFailureBlock)failure;

@end
