#import "_MRSLUser.h"

#import "MRSLImageRequestable.h"

@interface MRSLUser : _MRSLUser <MRSLImageRequestable>

+ (MRSLUser *)currentUser;
+ (NSString *)apiTokenForCurrentUser;
+ (BOOL)currentUserOwnsMorselWithCreatorID:(int)creatorID;
+ (void)refreshCurrentUserWithSuccess:(MRSLAPISuccessBlock)userSuccessOrNil failure:(MRSLFailureBlock)failureOrNil;
+ (void)createOrUpdateUserFromResponseObject:(id)responseObject shouldMorselNotification:(BOOL)shouldMorselNotifications;
+ (void)updateCurrentUserToProfessional;
+ (void)resetThirdPartySettings;

- (BOOL)isCurrentUser;
- (BOOL)isProfessional;
- (BOOL)shouldTrack;
- (NSString *)fullName;
- (NSString *)displayName;
- (NSString *)fullNameOrTwitterHandle;
- (NSURLRequest *)imageURLRequestForImageSizeType:(MRSLImageSizeType)type;

- (void)setThirdPartySettings;

@end
