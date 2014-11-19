#import "_MRSLUser.h"

#import "MRSLImageRequestable.h"
#import "MRSLReportable.h"

@interface MRSLUser : _MRSLUser <MRSLImageRequestable, MRSLReportable>

+ (BOOL)currentUserOwnsMorselWithCreatorID:(int)creatorID;
+ (BOOL)isCurrentUserGuest;

+ (NSString *)apiTokenForCurrentUser;

+ (MRSLUser *)currentUser;
+ (MRSLUser *)createOrUpdateUserFromResponseObject:(id)responseObject existingUser:(BOOL)existingUser;
+ (MRSLUser *)createGuestUser;

+ (void)updateCurrentUserToProfessional;
+ (void)resetThirdPartySettings;
+ (void)incrementCurrentUserDraftCount;
+ (void)decrementCurrentUserDraftCount;

+ (void)API_updateNotificationsAmount:(MRSLAPICountBlock)amountOrNil
                              failure:(MRSLFailureBlock)failureOrNil;
+ (void)API_refreshCurrentUserWithSuccess:(MRSLAPISuccessBlock)userSuccessOrNil
                                  failure:(MRSLFailureBlock)failureOrNil;

- (BOOL)isCurrentUser;
- (BOOL)isGuestUser;
- (BOOL)hasEmptyName;
- (BOOL)isProfessional;

- (CGFloat)profileInformationHeight;

- (NSString *)fullName;
- (NSString *)displayName;
- (NSString *)fullNameOrTwitterHandle;
- (NSMutableAttributedString *)profileInformation;
- (NSURLRequest *)imageURLRequestForImageSizeType:(MRSLImageSizeType)type;

- (void)setThirdPartySettings;

- (void)API_updateImage;

@end
