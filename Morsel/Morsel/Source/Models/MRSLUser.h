#import "_MRSLUser.h"

@interface MRSLUser : _MRSLUser

+ (MRSLUser *)currentUser;
+ (NSString *)apiTokenForCurrentUser;
+ (BOOL)currentUserOwnsMorselWithCreatorID:(int)creatorID;
+ (void)createOrUpdateUserFromResponseObject:(id)responseObject shouldMorselNotification:(BOOL)shouldMorselNotifications;

- (BOOL)isCurrentUser;
- (BOOL)shouldTrack;
- (NSString *)fullName;
- (NSString *)displayName;
- (NSString *)industryTypeName;
- (NSURLRequest *)userProfilePictureURLRequestForImageSizeType:(MRSLProfileImageSizeType)type;

- (MRSLIndustryType)industryTypeEnum;
- (void)setIndustryTypeEnum:(MRSLIndustryType)type;

@end
