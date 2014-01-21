#import "_MRSLUser.h"

typedef NS_ENUM(NSUInteger, UserOccupationType)
{
    UserOccupationTypeChef,
    UserOccupationTypeDiner,
    UserOccupationTypeMedia
};

@interface MRSLUser : _MRSLUser

- (NSString *)fullName;
- (BOOL)isCurrentUser;
- (UserOccupationType)occupationTypeRaw;

- (void)addPost:(MRSLPost *)post;

- (void)retrieveProfileImageWithSuccess:(MorselImageDownloadSuccessBlock)successOrNil
                                failure:(MorselImageDownloadFailureBlock)failureOrNil;

- (void)setOccupationTypeRaw:(UserOccupationType)type;
- (void)setWithDictionary:(NSDictionary *)dictionary
                inContext:(NSManagedObjectContext *)contextOrNil;

@end
