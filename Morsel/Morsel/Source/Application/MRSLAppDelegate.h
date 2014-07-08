//
//  MRSLAppDelegate.h
//  Morsel
//
//  Created by Javier Otero on 12/6/13.
//  Copyright (c) 2013 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MRSLAPIService;
@class MRSLS3Service;

@interface MRSLAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) MRSLAPIService *apiService;
@property (strong, nonatomic) MRSLS3Service *s3Service;
@property (strong, nonatomic) NSDateFormatter *defaultDateFormatter;
@property (strong, nonatomic) UIWindow *window;

- (void)resetDataStore;
- (void)resetSocialConnections;

@end
