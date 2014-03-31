//
//  MRSLAppDelegate+CustomURLSchemes.h
//  Morsel
//
//  Created by Marty Trzpit on 4/1/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

@interface UIResponder (CustomURLSchemes)

- (void)setupRouteHandler;

- (BOOL)handleRouteForURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication;

@end
