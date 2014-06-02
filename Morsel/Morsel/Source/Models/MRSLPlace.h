#import "_MRSLPlace.h"

@interface MRSLPlace : _MRSLPlace {}

- (NSString *)cityState;
- (NSString *)fullAddress;

- (NSArray *)contactInfo;
- (NSArray *)hourInfo;
- (NSArray *)diningInfo;
- (NSArray *)directionsInfo;

@end
