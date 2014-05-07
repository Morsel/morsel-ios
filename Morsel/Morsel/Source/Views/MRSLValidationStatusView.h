//
//  MRSLValidationStatusView.h
//  Morsel
//
//  Created by Javier Otero on 5/8/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MRSLValidationStatusView : UIView

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
