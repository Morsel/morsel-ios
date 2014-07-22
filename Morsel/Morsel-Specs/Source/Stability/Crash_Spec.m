//
//  Crash_Spec.m
//  Morsel
//
//  Created by Javier Otero on 2/20/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <Kiwi/Kiwi.h>

#import "MRSLCaptureMultipleMediaViewController.h"

#import "MRSLItem.h"
#import "MRSLUser.h"

@interface MRSLBaseCaptureMediaViewController (Private)

@property (nonatomic) AVCaptureSession *session;

- (void)endCameraSession;

@end

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

/*
 Testflight Crash Reports associated to this case:
 * https://www.testflightapp.com/dashboard/builds/crashes/9549606/23413879/
*/

describe(@"CaptureMediaViewController", ^{
    MRSLCaptureMultipleMediaViewController *captureMediaVC = [[UIStoryboard mediaManagementStoryboard] instantiateViewControllerWithIdentifier:@"sb_MRSLCaptureMultipleMediaViewController"];
    context(@"attempts to end camera session in quick succession", ^{
            [captureMediaVC endCameraSession];
            [captureMediaVC endCameraSession];
        it(@"should end session and not crash", ^{
            [[theValue(captureMediaVC.session.running) should] beNo];
        });
    });
});

SPEC_END
