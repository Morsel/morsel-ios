#import "MRSLPlace.h"

#import "MRSLPlaceInfo.h"

@interface MRSLPlace ()

@end

@implementation MRSLPlace

#pragma mark - Instance Methods

- (NSString *)cityState {
    return [NSString stringWithFormat:@"%@, %@", self.city, self.state];
}

- (NSString *)fullAddress {
    return [NSString stringWithFormat:@"%@\n%@, %@ %@", self.address, self.city, self.state, self.postal_code];
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
    NSMutableArray *info = [NSMutableArray array];
    return info;
}

- (NSArray *)diningInfo {
    NSMutableArray *info = [NSMutableArray array];
    if (self.price_tier) [info addObject:[[MRSLPlaceInfo alloc] initWithPrimaryInfo:@"Price:"
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

#pragma mark - Magical Record Methods

- (void)didImport:(id)data {
    
}

@end