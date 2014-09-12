//
//  MRSLEventManager.m
//  Morsel
//
//  Created by Javier Otero on 2/17/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLEventManager.h"

#import "MRSLItem.h"
#import "MRSLMorsel.h"
#import "MRSLUser.h"

@interface MRSLEventManager ()

@property (strong, nonatomic) NSMutableArray *viewedItems;
@property (strong, nonatomic) NSMutableArray *viewedMorsels;

@property (nonatomic) NSTimeInterval sessionStartedAt;

@end

@implementation MRSLEventManager

#pragma mark - Class Methods

+ (instancetype)sharedManager {
    static MRSLEventManager *_sharedManager = nil;
    static dispatch_once_t once;

    dispatch_once(&once, ^{
        _sharedManager = [[MRSLEventManager alloc] init];
    });

    return _sharedManager;
}

- (id)init {
    self = [super init];
    if (self) {
        self.viewedItems = [NSMutableArray array];
        self.viewedMorsels = [NSMutableArray array];
        self.sessionStartedAt = [NSDate timeIntervalSinceReferenceDate];
    }
    return self;
}

- (void)registerItem:(MRSLItem *)item {
    if (!item) return;
    NSNumber *itemID = @(item.itemIDValue);
    BOOL itemIDFound = CFArrayContainsValue ((__bridge CFArrayRef)_viewedItems,
                                               CFRangeMake(0, _viewedItems.count),
                                               (CFNumberRef)itemID);
    if (!itemIDFound) {
        [_viewedItems addObject:itemID];
        self.items_viewed++;
    }
}

- (void)registerMorsel:(MRSLMorsel *)morsel {
    if (!morsel) return;
    NSNumber *morselID = @(morsel.morselIDValue);
    BOOL morselIDFound = CFArrayContainsValue ((__bridge CFArrayRef)_viewedMorsels,
                                               CFRangeMake(0, _viewedMorsels.count),
                                               (CFNumberRef)morselID);
    if (!morselIDFound) {
        [_viewedMorsels addObject:morselID];
        self.morsels_seen++;
    }
}

- (void)track:(NSString *)event {
    [self track:event properties:nil];
}

- (void)track:(NSString *)event
   properties:(NSDictionary *)properties {
#if defined (SPEC_TESTING) || defined (INTEGRATION_TESTING)
    //  Don't track events when running tests
    return;
#else
    NSMutableDictionary *sessionAndProperties = [NSMutableDictionary dictionaryWithDictionary:properties];
    [sessionAndProperties addEntriesFromDictionary:[self sessionDictionary]];
    [[Mixpanel sharedInstance] track:event
                          properties:sessionAndProperties];
#endif
}

- (CGFloat)sessionTimeInMinutes {
    NSTimeInterval sessionTime = [NSDate timeIntervalSinceReferenceDate] - self.sessionStartedAt;
    CGFloat sessionTimeInMinutes = sessionTime / 60.f;
    return sessionTimeInMinutes;
}

- (NSDictionary *)sessionDictionary {
    NSString *sessionTimeFormatted = [NSString stringWithFormat:@"%.2f", [self sessionTimeInMinutes]];
    return @{@"morsels_seen": @(self.morsels_seen),
             @"items_viewed": @(self.items_viewed),
             @"comments_added": @(self.comments_added),
             @"likes_given": @(self.likes_given),
             @"users_followed": @(self.users_followed),
             @"places_followed": @(self.places_followed),
             @"new_morsels_created": @(self.new_morsels_created),
             @"morsels_published": @(self.morsels_published),
             @"morsels_shared_to_fb": @(self.morsels_shared_to_fb),
             @"morsels_shared_to_twitter": @(self.morsels_shared_to_twitter),
             @"session_length": NSNullIfNil(sessionTimeFormatted),
             @"user_id": NSNullIfNil([[MRSLUser currentUser] userID])};
}

- (void)startSession {
    [self track:@"App Entered Foreground" properties:[self sessionDictionary]];

    self.morsels_seen = 0;
    self.items_viewed = 0;
    self.comments_added = 0;
    self.likes_given = 0;
    self.users_followed = 0;
    self.places_followed = 0;
    self.new_morsels_created = 0;
    self.morsels_published = 0;
    self.morsels_shared_to_fb = 0;
    self.morsels_shared_to_twitter = 0;

    [self.viewedItems removeAllObjects];
    [self.viewedMorsels removeAllObjects];

    self.sessionStartedAt = [NSDate timeIntervalSinceReferenceDate];
}

- (void)endSession {
    [self track:@"App Entered Background" properties:[self sessionDictionary]];
}

@end
