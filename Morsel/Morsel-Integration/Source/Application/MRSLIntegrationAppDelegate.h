//
//  MRSLIntegrationAppDelegate.h
//  Morsel
//
//  Created by Javier Otero on 7/30/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MRSLAPIService;
@class MRSLS3Service;

@interface MRSLIntegrationAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) MRSLAPIService *apiService;
@property (strong, nonatomic) MRSLS3Service *s3Service;
@property (strong, nonatomic) NSDateFormatter *defaultDateFormatter;
@property (strong, nonatomic) UIWindow *window;

- (void)resetDataStore;
- (void)resetSocialConnections;

@end
