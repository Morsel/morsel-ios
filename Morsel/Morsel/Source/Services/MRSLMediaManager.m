//
//  MRSLMediaManager.m
//  Morsel
//
//  Created by Javier Otero on 4/7/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLMediaManager.h"

#import <SDWebImage/SDWebImageManager.h>

#import "MRSLMorsel.h"
#import "MRSLPost.h"

@interface MRSLMediaManager ()

@property (strong, nonatomic) SDWebImageManager *webImageManager;

@end

@implementation MRSLMediaManager

#pragma mark - Class Methods

+ (instancetype)sharedManager {
    static MRSLMediaManager *_sharedManager = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _sharedManager = [[MRSLMediaManager alloc] init];
    });
    return _sharedManager;
}

#pragma mark - Instance Methods

- (id)init {
    self = [super init];
    if (self) {
        self.webImageManager = [[SDWebImageManager alloc] init];
    }
    return self;
}

- (void)queueCoverMediaForPosts:(NSArray *)posts {
    [_webImageManager cancelAll];
    [posts enumerateObjectsUsingBlock:^(MRSLPost *post, NSUInteger idx, BOOL *stop) {
        [self queueMorselsInPost:post
                    preloadCover:(idx == 0) ? NO : YES];
    }];
}

- (void)queueMorselsInPost:(MRSLPost *)post
              preloadCover:(BOOL)shouldPreloadCover {
    DDLogDebug(@"Preloading images for post with title: %@", post.title);
    __block int morselCount = 0;
    MRSLMorsel *coverMorsel = nil;
    if (shouldPreloadCover) {
        DDLogDebug(@"Cover image preloading for post with title: %@", post.title);
        coverMorsel = [MRSLMorsel MR_findFirstByAttribute:MRSLMorselAttributes.morselID
                                                withValue:post.primary_morsel_id] ?: [post.morselsArray lastObject];
        [self queueRequestForMorsel:coverMorsel
                           withType:MorselImageSizeTypeLarge
                       highPriority:YES];
    }

    [post.morselsArray enumerateObjectsUsingBlock:^(MRSLMorsel *morsel, NSUInteger idx, BOOL *stop) {
        if (![morsel isEqual:coverMorsel]) {
            [self queueRequestForMorsel:morsel
                               withType:MorselImageSizeTypeLarge
                           highPriority:NO];
            if (morselCount < 4) {
                [self queueRequestForMorsel:morsel
                                   withType:MorselImageSizeTypeThumbnail
                               highPriority:YES];
            }
            morselCount++;
        }
    }];
}

- (void)queueRequestForMorsel:(MRSLMorsel *)morsel
                     withType:(MorselImageSizeType)morselImageSizeType
                 highPriority:(BOOL)isHighPriority {
    NSURLRequest *morselRequest = [morsel morselPictureURLRequestForImageSizeType:morselImageSizeType];
    [_webImageManager downloadWithURL:morselRequest.URL
                              options:(isHighPriority) ? SDWebImageHighPriority : SDWebImageLowPriority
                             progress:nil
                            completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
                                DDLogDebug(@"Image preloaded");
                                // Completion block must be set otherwise SDWebImageManager throws an exception
                            }];
}

@end
