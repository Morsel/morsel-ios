//
//  MRSLSpecsAppDelegate.h
//  Morsel
//
//  Created by Javier Otero on 2/27/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MorselAPIService;

@interface MRSLSpecsAppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) MorselAPIService *morselApiService;
@property (nonatomic, strong) NSDateFormatter *defaultDateFormatter;
@property (strong, nonatomic) UIWindow *window;

- (void)resetDataStore;

@end
