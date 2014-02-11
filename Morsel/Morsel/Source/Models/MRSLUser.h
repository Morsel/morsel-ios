#import "_MRSLUser.h"

typedef NS_ENUM(NSUInteger, ProfileImageSizeType) {
    ProfileImageSizeTypeSmall,
    ProfileImageSizeTypeMedium
};

@interface MRSLUser : _MRSLUser

+ (MRSLUser *)currentUser;
+ (NSString *)apiTokenForCurrentUser;
+ (BOOL)currentUserOwnsMorselWithCreatorID:(int)creatorID;
+ (void)createOrUpdateUserFromResponseObject:(id)responseObject shouldPostNotification:(BOOL)shouldPostNotifications;

- (BOOL)isCurrentUser;
- (NSString *)fullName;
- (NSURLRequest *)userProfilePictureURLRequestForImageSizeType:(ProfileImageSizeType)type;
- (void)incrementDraftCountAndSave;
- (void)decrementDraftCountAndSave;

@end
