//
//  MRSLPreviewMediaViewController.h
//  Morsel
//
//  Created by Javier Otero on 3/4/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MRSLMediaItem;

@protocol MRSLImagePreviewViewControllerDelegate <NSObject>

@optional
- (void)imagePreviewDidDeleteMediaItem:(MRSLMediaItem *)mediaItem;

@end

@interface MRSLImagePreviewViewController : UIViewController

@property (weak, nonatomic) id <MRSLImagePreviewViewControllerDelegate> delegate;

- (void)setPreviewMedia:(NSMutableArray *)media andStartingIndex:(NSUInteger)index;

@end
