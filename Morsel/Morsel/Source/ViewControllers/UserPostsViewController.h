//
//  UserPostsViewController.h
//  Morsel
//
//  Created by Javier Otero on 1/27/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MRSLPost;

@interface UserPostsViewController : UIViewController

@property (nonatomic, strong) NSString *postTitle;
@property (nonatomic, strong) MRSLPost *post;

@end
