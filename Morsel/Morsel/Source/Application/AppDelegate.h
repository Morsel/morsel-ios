//
//  AppDelegate.h
//  Morsel
//
//  Created by Javier Otero on 12/6/13.
//  Copyright (c) 2013 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MorselAPIService;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) MorselAPIService *morselApiService;
@property (nonatomic, strong) NSDateFormatter *defaultDateFormatter;
@property (strong, nonatomic) UIWindow *window;

- (void)resetDataStore;

@end
