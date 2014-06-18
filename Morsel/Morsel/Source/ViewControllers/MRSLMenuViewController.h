//
//  MRSLMenuViewController.h
//  Morsel
//
//  Created by Javier Otero on 6/17/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MRSLMenuViewControllerDelegate <NSObject>

@optional
- (void)menuViewControllerDidSelectMenuOption:(NSString *)menuOption;

@end

@interface MRSLMenuViewController : UIViewController

@property (weak, nonatomic) id <MRSLMenuViewControllerDelegate> delegate;

@end
