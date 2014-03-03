//
//  UserPostsViewController.h
//  Morsel
//
//  Created by Javier Otero on 1/27/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MRSLPost;

@protocol UserPostsViewControllerDelegate <NSObject>

@optional
- (void)userPostsSelectedPost:(MRSLPost *)post;
- (void)userPostsSelectedOriginalMorsel;

@end

@interface MRSLUserPostsViewController : UIViewController

@property (nonatomic, weak) id<UserPostsViewControllerDelegate> delegate;

@property (nonatomic, weak) IBOutlet UICollectionView *postCollectionView;

@property (nonatomic, strong) NSString *temporaryPostTitle;

@property (nonatomic, strong) MRSLPost *post;
@property (nonatomic, strong) MRSLMorsel *morsel;

@end
