//
//  MorselDetailCommentsViewController.h
//  Morsel
//
//  Created by Javier Otero on 1/31/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MorselDetailCommentsViewControllerDelegate <NSObject>

@optional
- (void)morselDetailCommentsViewControllerDidUpdateWithAmountOfComments:(NSUInteger)amount;

@end

@class MRSLMorsel;

@interface MorselDetailCommentsViewController : UIViewController

@property (nonatomic, weak) id <MorselDetailCommentsViewControllerDelegate> delegate;

@property (nonatomic, strong) MRSLMorsel *morsel;

@end
