#import "_MRSLPlace.h"

@interface MRSLPlace : _MRSLPlace {}

- (NSString *)fullAddress;

- (NSArray *)contactInfo;
- (NSArray *)hourInfo;
- (NSArray *)diningInfo;
- (NSArray *)directionsInfo;
- (NSArray *)placeTimeFrames;

- (CGFloat)detailsCellHeight;
- (BOOL)hasMenuLink;
- (BOOL)hasReservationLink;

@end
