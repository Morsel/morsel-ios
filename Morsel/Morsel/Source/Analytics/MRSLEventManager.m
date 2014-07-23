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
#if defined (SPEC_TESTING) || defined (INTEGRATION_TESTING)
    //  Don't track events when running tests
    return;
#else
    [[Mixpanel sharedInstance] track:event
                          properties:properties];
#endif
}

@end
