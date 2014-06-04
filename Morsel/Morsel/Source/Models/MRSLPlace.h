#import "_MRSLPlace.h"

@interface MRSLPlace : _MRSLPlace {}

- (NSString *)fullAddress;

- (NSArray *)contactInfo;
- (NSArray *)hourInfo;
- (NSArray *)diningInfo;
- (NSArray *)directionsInfo;

@end
