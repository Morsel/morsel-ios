//
//  MRSLSocialComposeViewController.h
//  Morsel
//
//  Created by Javier Otero on 5/14/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MRSLSocialComposeViewController : MRSLBaseViewController

@property (nonatomic) enum MRSLSocialAccountType accountType;

@property (strong, nonatomic) MRSLSocialSuccessBlock successBlock;
@property (strong, nonatomic) MRSLSocialCancelBlock cancelBlock;

@property (weak, nonatomic) MRSLMorsel *morsel;
@property (weak, nonatomic) NSString *placeholderText;

@end
