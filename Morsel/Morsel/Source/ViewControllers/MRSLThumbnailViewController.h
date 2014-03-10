//
//  MorselThumbnailViewController.h
//  Morsel
//
//  Created by Javier Otero on 1/24/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MRSLMorsel, MRSLPost;

@protocol MorselThumbnailViewControllerDelegate <NSObject>

@optional
- (void)morselThumbnailDidSelectMorsel:(MRSLMorsel *)morsel;
- (void)morselThumbnailDidSelectClose;

@end

@interface MRSLThumbnailViewController : UIViewController

@property (weak, nonatomic) id<MorselThumbnailViewControllerDelegate> delegate;

@property (strong, nonatomic) MRSLPost *post;

@end