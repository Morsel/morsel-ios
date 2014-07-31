//
//  MRSLMediaManager.m
//  Morsel
//
//  Created by Javier Otero on 4/7/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLMediaManager.h"

#import <SDWebImage/SDWebImageManager.h>

#import "MRSLItem.h"
#import "MRSLMorsel.h"

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
        [self.webImageManager.imageDownloader setMaxConcurrentDownloads:5];
        SDWebImageManager *sharedManager = [SDWebImageManager sharedManager];
        [sharedManager.imageDownloader setMaxConcurrentDownloads:5];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reset)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
    }
    return self;
}

- (void)queueCoverMediaForMorsels:(NSArray *)morsels {
    [_webImageManager cancelAll];
    [morsels enumerateObjectsUsingBlock:^(MRSLMorsel *morsel, NSUInteger idx, BOOL *stop) {
        [self queueMorselsInMorsel:morsel
                    preloadCover:(idx == 0) ? NO : YES];
    }];
}

- (void)queueMorselsInMorsel:(MRSLMorsel *)morsel
              preloadCover:(BOOL)shouldPreloadCover {
    DDLogVerbose(@"Preloading images for morsel with title: %@", morsel.title);
    __block int itemCount = 0;
    MRSLItem *coverMorsel = nil;
    if (shouldPreloadCover) {
        DDLogVerbose(@"Cover image preloading for morsel with title: %@", morsel.title);
        coverMorsel = [MRSLItem MR_findFirstByAttribute:MRSLItemAttributes.itemID
                                                withValue:morsel.primary_item_id] ?: [morsel.itemsArray lastObject];
        [self queueRequestForMorsel:coverMorsel
                           withType:MRSLImageSizeTypeLarge
                       highPriority:YES];
    }

    [morsel.itemsArray enumerateObjectsUsingBlock:^(MRSLItem *item, NSUInteger idx, BOOL *stop) {
        if (![item isEqual:coverMorsel]) {
            [self queueRequestForMorsel:item
                               withType:MRSLImageSizeTypeLarge
                           highPriority:NO];
            if (itemCount < 4) {
                [self queueRequestForMorsel:item
                                   withType:MRSLImageSizeTypeSmall
                               highPriority:YES];
            }
            itemCount++;
        }
    }];
}

- (void)queueRequestForMorsel:(MRSLItem *)item
                     withType:(MRSLImageSizeType)imageSizeType
                 highPriority:(BOOL)isHighPriority {
    NSURLRequest *itemRequest = [item imageURLRequestForImageSizeType:imageSizeType];
    [_webImageManager downloadImageWithURL:itemRequest.URL
                              options:(isHighPriority) ? SDWebImageHighPriority : SDWebImageLowPriority
                             progress:nil
                            completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                DDLogVerbose(@"Image preloaded");
                                // Completion block must be set otherwise SDWebImageManager throws an exception
                            }];
}

- (void)reset {
    [self.webImageManager.imageCache clearMemory];
    [[SDWebImageManager sharedManager].imageCache clearMemory];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
