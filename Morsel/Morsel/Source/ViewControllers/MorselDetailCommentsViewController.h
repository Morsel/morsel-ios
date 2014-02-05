//
//  MorselDetailCommentsViewController.h
//  Morsel
//
//  Created by Javier Otero on 1/31/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MRSLMorsel, MRSLUser;

@protocol MorselDetailCommentsViewControllerDelegate <NSObject>

@optional
- (void)morselDetailCommentsViewControllerDidUpdateWithAmountOfComments:(NSUInteger)amount;
- (void)morselDetailCommentsViewControllerDidSelectUser:(MRSLUser *)user;

@end

@interface MorselDetailCommentsViewController : UIViewController

@property (nonatomic, weak) id <MorselDetailCommentsViewControllerDelegate> delegate;

@property (nonatomic, strong) MRSLMorsel *morsel;

@end
