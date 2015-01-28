#import "_MRSLMorsel.h"

#import "MRSLReportable.h"

@interface MRSLMorsel : _MRSLMorsel <MRSLReportable>

- (BOOL)hasCreatorInfo;
- (BOOL)hasPlaceholderTitle;
- (BOOL)hasTaggedUsers;

- (CGFloat)coverInformationHeight;

- (NSInteger)indexOfItem:(MRSLItem *)item;

- (NSDate *)latestUpdatedDate;
- (NSArray *)itemsArray;
- (NSString *)placeholderTitle;
- (NSString *)firstItemDescription;
- (NSData *)downloadCoverPhotoIfNilWithCompletion:(MRSLSuccessOrFailureBlock)completionOrNil;
- (NSMutableAttributedString *)thumbnailInformation;
- (NSString *)instagramString;

- (MRSLItem *)coverItem;

- (void)getCoverInformation:(MRSLAttributedStringBlock)attributedStringBlock;

@end
