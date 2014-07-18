#import "_MRSLMorsel.h"

@interface MRSLMorsel : _MRSLMorsel

- (NSDate *)latestUpdatedDate;
- (NSArray *)itemsArray;
- (MRSLItem *)coverItem;
- (BOOL)hasCreatorInfo;

@end
