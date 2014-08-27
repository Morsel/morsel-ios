#import "_MRSLMorsel.h"

#import "MRSLReportable.h"

@interface MRSLMorsel : _MRSLMorsel <MRSLReportable>

- (NSDate *)latestUpdatedDate;
- (NSArray *)itemsArray;
- (MRSLItem *)coverItem;
- (BOOL)hasCreatorInfo;
- (BOOL)hasPlaceholderTitle;
- (NSData *)downloadCoverPhotoIfNilWithCompletion:(MRSLSuccessOrFailureBlock)completionOrNil;

@end
