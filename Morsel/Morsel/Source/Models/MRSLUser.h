#import "_MRSLUser.h"

@interface MRSLUser : _MRSLUser

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
- (NSURLRequest *)userProfilePictureURLRequestForImageSizeType:(MRSLProfileImageSizeType)type;

- (MRSLIndustryType)industryTypeEnum;
- (void)setIndustryTypeEnum:(MRSLIndustryType)type;

- (void)setThirdPartySettings;

@end
