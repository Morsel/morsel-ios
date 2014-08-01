//
//  MRSLEventManager.h
//  Morsel
//
//  Created by Javier Otero on 2/17/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MRSLEventManager : NSObject

@property (nonatomic) int morsels_seen;
@property (nonatomic) int items_viewed;
@property (nonatomic) int comments_added;
@property (nonatomic) int likes_given;
@property (nonatomic) int users_followed;
@property (nonatomic) int places_followed;
@property (nonatomic) int new_morsels_created;
@property (nonatomic) int morsels_published;
@property (nonatomic) int morsels_shared_to_fb;
@property (nonatomic) int morsels_shared_to_twitter;

+ (instancetype)sharedManager;

- (void)registerItem:(MRSLItem *)item;
- (void)registerMorsel:(MRSLMorsel *)morsel;

- (void)track:(NSString *)event;

- (void)track:(NSString *)event
   properties:(NSDictionary *)properties;

- (void)startSession;
- (void)endSession;

@end
