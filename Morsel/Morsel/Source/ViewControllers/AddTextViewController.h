//
//  AddTextViewController.h
//  Morsel
//
//  Created by Javier Otero on 1/29/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddTextViewControllerDelegate <NSObject>

@optional
- (void)addTextViewDidBeginEditing;

@end

@class GCPlaceholderTextView;

@interface AddTextViewController : UIViewController

@property (nonatomic, weak) id<AddTextViewControllerDelegate> delegate;

@property (nonatomic, weak) IBOutlet GCPlaceholderTextView *textView;

@end
