//
//  ProfileImageView.h
//  Morsel
//
//  Created by Javier Otero on 12/13/13.
//  Copyright (c) 2013 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MRSLUser;

@protocol ProfileImageViewDelegate <NSObject>

@optional
- (void)profileImageViewDidSelectUser:(MRSLUser *)user;

@end

@interface MRSLProfileImageView : UIImageView

@property (nonatomic, weak) id <ProfileImageViewDelegate> delegate;

@property (nonatomic, weak) MRSLUser *user;

- (void)addAndRenderImage:(UIImage *)image;

@end
