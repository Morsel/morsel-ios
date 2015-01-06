//
//  Crash_Spec.m
//  Morsel
//
//  Created by Javier Otero on 2/20/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <Kiwi/Kiwi.h>

#import "MRSLItem.h"
#import "MRSLUser.h"

SPEC_BEGIN(CrashSpec)

/*
 Testflight Crash Reports associated to this case:
 * https://www.testflightapp.com/dashboard/builds/crashes/9549606/23481467/
 * https://www.testflightapp.com/dashboard/builds/crashes/9549606/23479193/
 * https://www.testflightapp.com/dashboard/builds/crashes/9549606/23480730/
*/

describe(@"AlertView", ^{
    context(@"+ showAlertViewForErrorString:delegate:", ^{
        __block UIAlertView *alert = nil;

        it(@"should not crash when passed a nil errorString", ^{
            @try {
                alert = [UIAlertView showAlertViewForErrorString:nil
                                                        delegate:nil];
            } @catch (NSException *exception) {
                fail(@"AlertView crashed");
            }
        });

        it(@"should display unknown error", ^{
            [[alert.message should] equal:@"Unknown error"];
        });

        afterAll(^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [alert dismissWithClickedButtonIndex:0
                                            animated:NO];
            });
        });
    });
});

SPEC_END
