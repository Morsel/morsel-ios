//
//  MRSLAppDelegate+CustomURLSchemes.m
//  Morsel
//
//  Created by Marty Trzpit on 4/1/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <JLRoutes/JLRoutes.h>

#import "MRSLAppDelegate+CustomURLSchemes.h"
#import "UIStoryboard+Morsel.h"

#import "MRSLProfileViewController.h"
#import "MRSLUser.h"

@interface UIResponder (CustomURLSchemes_Private)

- (BOOL)handleUserProfileRouteWithParameters:(NSDictionary *)parameters;

@end

@implementation UIResponder (CustomURLSchemes)

- (void)setupRouteHandler {
    [JLRoutes addRoute:@"/users/:user_id" handler:^BOOL(NSDictionary *parameters) {
        return [self handleUserProfileRouteWithParameters:parameters];
    }];
}

- (BOOL)handleRouteForURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication {
    [JLRoutes routeURL:url];
    return YES;
}


#pragma mark - Private Methods

- (BOOL)handleUserProfileRouteWithParameters:(NSDictionary *)parameters {
    if (parameters[@"user_id"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:MRSLAppShouldDisplayUserProfileNotification
                                                            object:parameters];
        return YES;
    }

    return NO;
}

@end
