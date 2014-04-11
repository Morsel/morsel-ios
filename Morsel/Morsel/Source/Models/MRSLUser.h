#import "_MRSLUser.h"

typedef NS_ENUM(NSUInteger, ProfileImageSizeType) {
    ProfileImageSizeTypeSmall,
    ProfileImageSizeTypeMedium
};

@interface MRSLUser : _MRSLUser

+ (MRSLUser *)currentUser;
+ (NSString *)apiTokenForCurrentUser;
+ (BOOL)currentUserOwnsMorselWithCreatorID:(int)creatorID;
+ (void)createOrUpdateUserFromResponseObject:(id)responseObject shouldMorselNotification:(BOOL)shouldMorselNotifications;

- (BOOL)isCurrentUser;
- (BOOL)shouldTrack;
- (NSString *)fullName;
- (NSString *)displayName;
- (NSURLRequest *)userProfilePictureURLRequestForImageSizeType:(ProfileImageSizeType)type;

@end
