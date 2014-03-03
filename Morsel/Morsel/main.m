//
//  main.m
//  Morsel
//
//  Created by Javier Otero on 12/6/13.
//  Copyright (c) 2013 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

#if defined (SPEC_TESTING) || defined (INTEGRATION_TESTING)
#define _appDelClassString @"MRSLSpecsAppDelegate"
#else
#define _appDelClassString @"AppDelegate"
#endif

int main(int argc, char * argv[]) {
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, _appDelClassString);
    }
}