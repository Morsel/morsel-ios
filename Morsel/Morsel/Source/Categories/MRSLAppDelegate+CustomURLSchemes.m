//
//  MRSLAppDelegate+CustomURLSchemes.m
//  Morsel
//
//  Created by Marty Trzpit on 4/1/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <JLRoutes/JLRoutes.h>

#import "MRSLAppDelegate+CustomURLSchemes.h"

#import "MRSLUser.h"

@interface UIResponder (CustomURLSchemes_Private)

- (BOOL)handleUserProfileRouteWithParameters:(NSDictionary *)parameters;

@end

@implementation UIResponder (CustomURLSchemes)

- (void)setupRouteHandler {
    [JLRoutes addRoute:@"/users/:user_id" handler:^BOOL(NSDictionary *parameters) {
        return [self handleRouteWithParameters:parameters];
    }];
    [JLRoutes addRoute:@"/morsels/:morsel_id" handler:^BOOL(NSDictionary *parameters) {
        return [self handleRouteWithParameters:parameters];
    }];
    [JLRoutes addRoute:@"/places/:place_id" handler:^BOOL(NSDictionary *parameters) {
        return [self handleRouteWithParameters:parameters];
    }];
}

- (BOOL)handleRouteForURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication {
    [JLRoutes routeURL:url];
    return YES;
}


#pragma mark - Private Methods

- (BOOL)handleRouteWithParameters:(NSDictionary *)parameters {
    if (![MRSLUser currentUser]) return NO;
    if (parameters[@"user_id"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:MRSLAppShouldDisplayUserProfileNotification
                                                            object:parameters];
        return YES;
    }
    if (parameters[@"morsel_id"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:MRSLAppShouldDisplayMorselDetailNotification
                                                            object:parameters];
        return YES;
    }
    if (parameters[@"place_id"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:MRSLAppShouldDisplayPlaceNotification
                                                            object:parameters];
        return YES;
    }

    return NO;
}

@end
