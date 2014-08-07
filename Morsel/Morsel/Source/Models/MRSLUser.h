#import "_MRSLUser.h"

#import "MRSLImageRequestable.h"

@interface MRSLUser : _MRSLUser <MRSLImageRequestable>

+ (MRSLUser *)currentUser;
+ (NSString *)apiTokenForCurrentUser;
+ (BOOL)currentUserOwnsMorselWithCreatorID:(int)creatorID;
+ (MRSLUser *)createOrUpdateUserFromResponseObject:(id)responseObject existingUser:(BOOL)existingUser;
+ (void)updateCurrentUserToProfessional;
+ (void)resetThirdPartySettings;
+ (void)API_updateNotificationsAmount:(MRSLAPICountBlock)amountOrNil
                              failure:(MRSLFailureBlock)failureOrNil;
+ (void)API_refreshCurrentUserWithSuccess:(MRSLAPISuccessBlock)userSuccessOrNil
                                  failure:(MRSLFailureBlock)failureOrNil;
+ (void)incrementCurrentUserDraftCount;
+ (void)decrementCurrentUserDraftCount;

- (BOOL)isCurrentUser;
- (BOOL)isProfessional;
- (NSString *)fullName;
- (NSString *)displayName;
- (NSString *)fullNameOrTwitterHandle;
- (NSURLRequest *)imageURLRequestForImageSizeType:(MRSLImageSizeType)type;

- (void)setThirdPartySettings;

- (void)API_updateImage;

@end
