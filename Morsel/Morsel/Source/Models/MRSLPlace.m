#import "MRSLPlace.h"

#import "MRSLPlaceInfo.h"
#import "MRSLPlaceTimeframe.h"

@interface MRSLPlace ()

@property (weak, nonatomic) NSArray *timeframes;

@end

@implementation MRSLPlace

@synthesize timeframes = _timeframes;

#pragma mark - Class Methods

+ (NSString *)API_identifier {
    return MRSLPlaceAttributes.placeID;
}

#pragma mark - Instance Methods

- (NSString *)fullAddress {
    NSMutableString *fullAddress = [NSMutableString string];
    if (self.address)       [fullAddress appendCommaSeparatedString:self.address];
    if ([fullAddress length] > 0 && ([self.city length] > 0 || [self.state length] > 0 || [self.postal_code length] > 0)) [fullAddress appendString:@"\n"];
    if (self.city)          [fullAddress appendCommaSeparatedString:self.city];
    if (self.state)         [fullAddress appendCommaSeparatedString:self.state];
    if (self.postal_code)   [fullAddress appendCommaSeparatedString:self.postal_code];
    return fullAddress;
}

- (NSArray *)contactInfo {
    NSMutableArray *info = [NSMutableArray array];
    if (self.formatted_phone) [info addObject:[[MRSLPlaceInfo alloc] initWithPrimaryInfo:@"phone"
                                                                        andSecondaryInfo:self.formatted_phone]];
    if (self.twitter_username) [info addObject:[[MRSLPlaceInfo alloc] initWithPrimaryInfo:@"twitter"
                                                                         andSecondaryInfo:self.twitter_username]];
    if (self.website_url) [info addObject:[[MRSLPlaceInfo alloc] initWithPrimaryInfo:@"website"
                                                                    andSecondaryInfo:self.website_url]];
    return info;
}

- (NSArray *)hourInfo {
    __block NSMutableArray *info = [NSMutableArray array];
    if ([[self placeTimeFrames] count] > 0) {
        [self.timeframes enumerateObjectsUsingBlock:^(MRSLPlaceTimeframe *timeframe, NSUInteger idx, BOOL *stop) {
            [info addObject:[[MRSLPlaceInfo alloc] initWithPrimaryInfo:timeframe.days
                                                      andSecondaryInfo:[timeframe.hours componentsJoinedByString:@"\n"]]];
        }];
    }
    return info;
}

- (NSArray *)diningInfo {
    NSMutableArray *info = [NSMutableArray array];
    if (self.price_tierValue > 0) [info addObject:[[MRSLPlaceInfo alloc] initWithPrimaryInfo:@"Price:"
                                                                   andSecondaryInfo:[@"" stringByPaddingToLength:self.price_tierValue withString:@"$" startingAtIndex:0]]];
    if (self.reservations) [info addObject:[[MRSLPlaceInfo alloc] initWithPrimaryInfo:@"Reservations:"
                                                                     andSecondaryInfo:self.reservations]];
    if (self.dress_code) [info addObject:[[MRSLPlaceInfo alloc] initWithPrimaryInfo:@"Dress Code:"
                                                                   andSecondaryInfo:self.dress_code]];
    if (self.dining_style) [info addObject:[[MRSLPlaceInfo alloc] initWithPrimaryInfo:@"Dining Style:"
                                                                     andSecondaryInfo:self.dining_style]];
    if (self.outdoor_seating) [info addObject:[[MRSLPlaceInfo alloc] initWithPrimaryInfo:@"Outdoor Seating:"
                                                                        andSecondaryInfo:self.outdoor_seating]];
    if (self.dining_options) [info addObject:[[MRSLPlaceInfo alloc] initWithPrimaryInfo:@"Dining Options:"
                                                                       andSecondaryInfo:self.dining_options]];
    if (self.credit_cards) [info addObject:[[MRSLPlaceInfo alloc] initWithPrimaryInfo:@"Credit Cards:"
                                                                     andSecondaryInfo:self.credit_cards]];
    return info;
}

- (NSArray *)directionsInfo {
    NSMutableArray *info = [NSMutableArray array];
    if (self.public_transit) [info addObject:[[MRSLPlaceInfo alloc] initWithPrimaryInfo:@"Public Transit:"
                                                                       andSecondaryInfo:self.public_transit]];
    if (self.parking) [info addObject:[[MRSLPlaceInfo alloc] initWithPrimaryInfo:@"Parking:"
                                                                andSecondaryInfo:self.parking]];
    if (self.parking_details) [info addObject:[[MRSLPlaceInfo alloc] initWithPrimaryInfo:@"Parking Details:"
                                                                        andSecondaryInfo:self.parking_details]];
    return info;
}

- (NSArray *)placeTimeFrames {
    if (self.timeframes) return self.timeframes;
    __block NSMutableArray *timeFrames = [NSMutableArray array];
    [self.foursquare_timeframes enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        NSMutableArray *timeslots = [NSMutableArray array];
        for (NSDictionary *timeslot in obj[@"open"]) {
            [timeslots addObject:timeslot[@"renderedTime"]];
        }
        MRSLPlaceTimeframe *placeTimeframe = [[MRSLPlaceTimeframe alloc] init];
        placeTimeframe.days = obj[@"days"];
        placeTimeframe.hours = timeslots;
        [timeFrames addObject:placeTimeframe];
    }];
    self.timeframes = timeFrames;
    return self.timeframes;
}

- (CGFloat)detailsCellHeight {
    CGFloat cellHeight = 185.0f;

    if (![self hasMenuLink]) cellHeight -= 45.0f;
    if (![self hasReservationLink]) cellHeight -= 45.0f;

    return cellHeight;
}

- (BOOL)hasMenuLink {
    return (self.menu_url != nil || self.menu_mobile_url != nil);
}

- (BOOL)hasReservationLink {
    return self.reservations_url != nil;
}


#pragma mark - Magical Record Methods

- (void)didImport:(id)data {
    
}

@end
