#import "_MRSLPost.h"

@interface MRSLPost : _MRSLPost

- (NSDate *)latestUpdatedDate;
- (NSArray *)morselsArray;
- (MRSLMorsel *)coverMorsel;

@end
