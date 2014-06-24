#import "_MRSLUser.h"

#import "MRSLImageRequestable.h"

@interface MRSLUser : _MRSLUser <MRSLImageRequestable>

+ (MRSLUser *)currentUser;
+ (NSString *)apiTokenForCurrentUser;
+ (BOOL)currentUserOwnsMorselWithCreatorID:(int)creatorID;
+ (void)refreshCurrentUserWithSuccess:(MRSLAPISuccessBlock)userSuccessOrNil failure:(MRSLFailureBlock)failureOrNil;
+ (void)createOrUpdateUserFromResponseObject:(id)responseObject shouldMorselNotification:(BOOL)shouldMorselNotifications;
+ (void)resetThirdPartySettings;

- (BOOL)isCurrentUser;
- (BOOL)isChef;
- (BOOL)shouldTrack;
- (NSString *)fullName;
- (NSString *)displayName;
- (NSString *)fullNameOrTwitterHandle;
- (NSString *)industryTypeName;
- (NSURLRequest *)imageURLRequestForImageSizeType:(MRSLImageSizeType)type;

- (MRSLIndustryType)industryTypeEnum;
- (void)setIndustryTypeEnum:(MRSLIndustryType)type;

- (void)setThirdPartySettings;

@end
