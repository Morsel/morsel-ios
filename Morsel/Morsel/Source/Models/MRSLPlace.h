#import "_MRSLPlace.h"

#import "MRSLReportable.h"

@interface MRSLPlace : _MRSLPlace <MRSLReportable>

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
