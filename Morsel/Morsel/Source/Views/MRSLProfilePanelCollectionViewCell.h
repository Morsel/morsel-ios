//
//  MRSLProfilePanelReusableView.h
//  Morsel
//
//  Created by Javier Otero on 5/23/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MRSLProfilePanelCollectionViewCellDelegate <NSObject>

@optional
- (void)profilePanelDidSelectFollowers;
- (void)profilePanelDidSelectFollowing;

@end

@interface MRSLProfilePanelCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) id <MRSLProfilePanelCollectionViewCellDelegate> delegate;

@property (weak, nonatomic) MRSLUser *user;

@end
