//
//  MRSLEventManager.m
//  Morsel
//
//  Created by Javier Otero on 2/17/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLEventManager.h"

#import "MRSLUser.h"

@interface MRSLEventManager ()

@property (strong, nonatomic) MRSLUser *currentUser;

@end

@implementation MRSLEventManager

#pragma mark - Class Methods

+ (instancetype)sharedManager {
    static MRSLEventManager *_sharedManager = nil;
    static dispatch_once_t once;

    dispatch_once(&once, ^{
        _sharedManager = [[MRSLEventManager alloc] init];
    });

    return _sharedManager;
}

- (void)track:(NSString *)event {
    [self track:event properties:nil];
}

- (void)track:(NSString *)event
   properties:(NSDictionary *)properties {
    if (!self.currentUser) self.currentUser = [MRSLUser currentUser];
    // If there is a current user and they have a title that is empty/nil, do not allow tracking.
    if (self.currentUser && ![self.currentUser shouldTrack]) return;
    [[Mixpanel sharedInstance] track:event
              properties:properties];
}

@end
