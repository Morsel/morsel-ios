//
//  MRSLAppDelegate.h
//  Morsel
//
//  Created by Javier Otero on 12/6/13.
//  Copyright (c) 2013 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MRSLAPIService;

@interface MRSLAppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) MRSLAPIService *morselApiService;
@property (nonatomic, strong) NSDateFormatter *defaultDateFormatter;
@property (strong, nonatomic) UIWindow *window;

- (void)resetDataStore;

@end
