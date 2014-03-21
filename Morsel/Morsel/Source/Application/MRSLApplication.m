//
//  MRSLApplication.m
//  Morsel
//
//  Created by Javier Otero on 3/21/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLApplication.h"

@implementation MRSLApplication

- (void)sendEvent:(UIEvent *)event {
    [super sendEvent:event];
    NSSet *allTouches = [event allTouches];
    if ([allTouches count] > 0) {
        UITouchPhase phase = ((UITouch *)[allTouches anyObject]).phase;
        if (phase == UITouchPhaseBegan) {
            [[NSNotificationCenter defaultCenter] postNotificationName:MRSLAppTouchPhaseDidBeginNotification
                                                                object:nil];
        }
    }
}

@end
