//
//  MRSLMediaItem.m
//  Morsel
//
//  Created by Javier Otero on 3/5/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLMediaItem.h"

@implementation MRSLMediaItem

- (void)processMediaToDataWithSuccess:(MRSLMediaItemProcessingSuccessBlock)successOrNil {
    __block NSData *fullImageData = nil;
    __block NSData *thumbImageData = nil;

    dispatch_queue_t queue = dispatch_queue_create("com.eatmorsel.morsel-add-image-processing", NULL);
    dispatch_queue_t main = dispatch_get_main_queue();

    dispatch_async(queue, ^{
        fullImageData = UIImageJPEGRepresentation(self.mediaFullImage, 1.f);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2f * NSEC_PER_SEC)), main, ^{
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2f * NSEC_PER_SEC)), main, ^{
                    dispatch_async(queue, ^{
                        thumbImageData = UIImageJPEGRepresentation(self.mediaThumbImage, .8f);
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2f * NSEC_PER_SEC)), main, ^{
                            dispatch_async(main, ^{
                                if (successOrNil) successOrNil(fullImageData, thumbImageData);
                            });
                        });
                });
            });
        });
    });
}

@end
