//
//  MRSLMorselPublishShareViewController.h
//  Morsel
//
//  Created by Javier Otero on 4/18/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MRSLMorselPublishShareViewController;

@protocol MRSLMorselPublishShareViewControllerDelegate<NSObject>

@optional
- (void)morselPublishShareViewController:(MRSLMorselPublishShareViewController *)morselPublishShareViewController
           viewWillDisappearWithSocialSettings:(NSDictionary *)socialSettings;

@end

@interface MRSLMorselPublishShareViewController : MRSLBaseViewController

@property (weak, nonatomic) id <MRSLMorselPublishShareViewControllerDelegate> delegate;

@property (strong, nonatomic) MRSLMorsel *morsel;

@end
