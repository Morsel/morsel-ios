//
//  MRSLPROInputAccessoryToolbar.h
//  Morsel
//
//  Created by Marty Trzpit on 1/29/15.
//  Copyright (c) 2015 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, MRSLPROPosition) {
    MRSLPROPositionNone = 0,
    MRSLPROPositionTop,
    MRSLPROPositionMiddle,
    MRSLPROPositionBottom
};

@class MRSLPROInputAccessoryToolbar;

@protocol MRSLPROInputAccessoryToolbarDelegate <NSObject>

@optional
- (void)inputAccessoryToolbarTappedDismissKeyboardButtonForToolbar:(MRSLPROInputAccessoryToolbar *)toolbar;
- (void)inputAccessoryToolbarTappedDownButtonForToolbar:(MRSLPROInputAccessoryToolbar *)toolbar;
- (void)inputAccessoryToolbarTappedUpButtonForToolbar:(MRSLPROInputAccessoryToolbar *)toolbar;

@end

@interface MRSLPROInputAccessoryToolbar : UIToolbar

@property (nonatomic, weak) id<MRSLPROInputAccessoryToolbarDelegate> inputAccessoryToolbarDelegate;

+ (instancetype)defaultInputAccessoryToolbarWithDelegate:(id<MRSLPROInputAccessoryToolbarDelegate>)inputAccessoryToolbarDelegate;

- (void)updatePosition:(MRSLPROPosition)newPosition;

@end
