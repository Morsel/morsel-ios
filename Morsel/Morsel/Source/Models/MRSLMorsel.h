#import "_MRSLMorsel.h"

#import "MRSLReportable.h"

@interface MRSLMorsel : _MRSLMorsel <MRSLReportable>

- (NSDate *)latestUpdatedDate;
- (NSArray *)itemsArray;
- (MRSLItem *)coverItem;
- (NSString *)firstItemDescription;
- (BOOL)hasCreatorInfo;
- (BOOL)hasPlaceholderTitle;
- (NSData *)downloadCoverPhotoIfNilWithCompletion:(MRSLSuccessOrFailureBlock)completionOrNil;

- (void)reloadTemplateDataIfNecessaryWithSuccess:(MRSLSuccessBlock)successOrNil
                                         failure:(MRSLFailureBlock)failureOrNil;

@end
