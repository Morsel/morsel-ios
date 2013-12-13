#import "_MRSLUser.h"

typedef NS_ENUM(NSUInteger, UserOccupationType)
{
    UserOccupationTypeChef,
    UserOccupationTypeDiner,
    UserOccupationTypeMedia
};

@interface MRSLUser : _MRSLUser

- (NSString *)fullName;
- (UserOccupationType)occupationTypeRaw;

- (void)addPost:(MRSLPost *)post;
- (void)setOccupationTypeRaw:(UserOccupationType)type;

@end
