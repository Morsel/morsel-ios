#import "_MRSLUser.h"

typedef NS_ENUM(NSUInteger, UserOccupationType) {
    UserOccupationTypeChef,
    UserOccupationTypeDiner,
    UserOccupationTypeMedia
};

typedef NS_ENUM(NSUInteger, ProfileImageSizeType) {
    ProfileImageSizeTypeSmall,
    ProfileImageSizeTypeMedium
};

@interface MRSLUser : _MRSLUser

+ (void)createOrUpdateUserFromResponseObject:(id)responseObject shouldPostNotification:(BOOL)shouldPostNotifications;

- (BOOL)isCurrentUser;
- (UserOccupationType)occupationTypeRaw;
- (NSURLRequest *)userProfilePictureURLRequestForImageSizeType:(ProfileImageSizeType)type;
- (NSString *)fullName;

- (void)addPost:(MRSLPost *)post;

- (void)setOccupationTypeRaw:(UserOccupationType)type;
- (void)setWithDictionary:(NSDictionary *)dictionary;

@end
