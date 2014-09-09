#import "MRSLUser.h"

#import "MRSLS3Service.h"
#import "MRSLAPIService+Profile.h"
#import "MRSLAPIService+Notifications.h"
#import "MRSLAPIService+Report.h"

#import "MRSLPresignedUpload.h"

static const int kGuestUserID = -1;

@implementation MRSLUser

#pragma mark - Class Methods

+ (NSString *)API_identifier {
    return MRSLUserAttributes.userID;
}

+ (MRSLUser *)currentUser {
    NSNumber *currentUserID = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"userID"];
    MRSLUser *currentUser = [MRSLUser MR_findFirstByAttribute:MRSLUserAttributes.userID
                                                    withValue:currentUserID
                                                    inContext:[NSManagedObjectContext MR_defaultContext]];
    return currentUser;
}

+ (NSString *)apiTokenForCurrentUser {
    MRSLUser *currentUser = [MRSLUser currentUser];

    return [NSString stringWithFormat:@"%i:%@", currentUser.userIDValue, currentUser.auth_token];
}

+ (BOOL)currentUserOwnsMorselWithCreatorID:(int)creatorID {
    return ([MRSLUser currentUser].userIDValue == creatorID);
}

+ (void)incrementCurrentUserDraftCount {
    MRSLUser *currentUser = [MRSLUser currentUser];
    currentUser.draft_count = @(MAX(currentUser.draft_countValue + 1, 0));
    [currentUser.managedObjectContext MR_saveOnlySelfAndWait];
}

+ (void)decrementCurrentUserDraftCount {
    MRSLUser *currentUser = [MRSLUser currentUser];
    currentUser.draft_count = @(MAX(currentUser.draft_countValue - 1, 0));
    [currentUser.managedObjectContext MR_saveOnlySelfAndWait];
}

+ (void)API_refreshCurrentUserWithSuccess:(MRSLAPISuccessBlock)userSuccessOrNil
                                  failure:(MRSLFailureBlock)failureOrNil {
    if ([MRSLUser isCurrentUserGuest]) return;
    MRSLUser *currentUser = [MRSLUser currentUser];
    if (!currentUser) return;

    [_appDelegate.apiService getUserProfile:currentUser
                                    success:userSuccessOrNil
                                    failure:failureOrNil];
}

+ (void)API_updateNotificationsAmount:(MRSLAPICountBlock)amountOrNil
                              failure:(MRSLFailureBlock)failureOrNil {
    if ([MRSLUser isCurrentUserGuest]) return;
#ifdef __IPHONE_8_0
    UIUserNotificationSettings *currentNotificationSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
    if (currentNotificationSettings.types != UIUserNotificationTypeBadge) {
        UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge
                                                                                             categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
        return;
    }
#endif
    if (![MRSLUser currentUser]) {
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        return;
    }
    [_appDelegate.apiService getUnreadCountWithSuccess:^(int countValue) {
        if (amountOrNil) amountOrNil(countValue);
    } failure:failureOrNil];
}

+ (MRSLUser *)createOrUpdateUserFromResponseObject:(id)userDictionary
                                existingUser:(BOOL)existingUser {
    NSNumber *userID = @([userDictionary[@"id"] intValue]);

    MRSLUser *user = [MRSLUser MR_findFirstByAttribute:MRSLUserAttributes.userID
                                             withValue:userID
                                             inContext:[NSManagedObjectContext MR_defaultContext]];
    if (!existingUser && !user) {
        // New User, find existing local record matching `username` from signup flow to grab photos
        user = [MRSLUser MR_findFirstByAttribute:MRSLUserAttributes.username
                                       withValue:userDictionary[@"username"]
                                       inContext:[NSManagedObjectContext MR_defaultContext]];
    }
    if (!user) {
        DDLogDebug(@"User did not exist on device. Creating new.");
        user = [MRSLUser MR_createInContext:[NSManagedObjectContext MR_defaultContext]];
    }

    [user MR_importValuesForKeysWithObject:userDictionary];

    [user setThirdPartySettings];

    [[NSUserDefaults standardUserDefaults] setObject:user.userID
                                              forKey:@"userID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [user.managedObjectContext MR_saveToPersistentStoreAndWait];

    if (existingUser) [[NSNotificationCenter defaultCenter] postNotificationName:MRSLServiceDidLogInUserNotification
                                                                          object:nil];

    return user;
}

+ (MRSLUser *)createGuestUser {
    MRSLUser *user = [MRSLUser MR_findFirstByAttribute:MRSLUserAttributes.userID
                                             withValue:@(kGuestUserID)
                                             inContext:[NSManagedObjectContext MR_defaultContext]];
    if (!user) {
        user = [MRSLUser MR_createInContext:[NSManagedObjectContext MR_defaultContext]];
    }
    user.userID = @(kGuestUserID);

    [[NSUserDefaults standardUserDefaults] setObject:user.userID
                                              forKey:@"userID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [user.managedObjectContext MR_saveToPersistentStoreAndWait];

    [[NSNotificationCenter defaultCenter] postNotificationName:MRSLServiceDidLogInUserNotification
                                                        object:nil];
    return user;
}

+ (void)updateCurrentUserToProfessional {
    [_appDelegate.apiService updateCurrentUserToProfessional:YES
                                                     success:nil
                                                     failure:nil];
}

+ (BOOL)isCurrentUserGuest {
    return [[self currentUser] isGuestUser];
}

+ (void)resetThirdPartySettings {
#if defined (ROLLBAR_ENVIRONMENT)
    [[Rollbar currentConfiguration] setPersonId:nil
                                       username:nil
                                          email:nil];
#endif
    [[Mixpanel sharedInstance] identify:nil];
    [[Mixpanel sharedInstance].people set:@{}];
}

#pragma mark - Instance Methods

- (BOOL)isCurrentUser {
    NSNumber *currentUserID = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"userID"];
    return ([currentUserID intValue] == self.userIDValue);
}

- (BOOL)isGuestUser {
    return (self.userIDValue == kGuestUserID);
}

- (BOOL)isProfessional {
    return self.professionalValue;
}

- (void)setThirdPartySettings {
    if ([MRSLUser isCurrentUserGuest]) {
        [[Mixpanel sharedInstance] registerSuperProperties:@{@"is_guest": @"true"}];
        return;
    } else {
        [[Mixpanel sharedInstance] registerSuperProperties:@{@"is_guest": @"false"}];
    }
    NSString *idString = [NSString stringWithFormat:@"%i", self.userIDValue];
#if defined (ROLLBAR_ENVIRONMENT)
    [[Rollbar currentConfiguration] setPersonId:idString
                                       username:self.username
                                          email:nil];
#endif
    [[Mixpanel sharedInstance] identify:idString];
    [[Mixpanel sharedInstance].people set:@{@"first_name": NSNullIfNil(self.first_name),
                                            @"last_name": NSNullIfNil(self.last_name),
                                            @"created_at": NSNullIfNil(self.creationDate),
                                            @"username": NSNullIfNil(self.username)}];
    [[Mixpanel sharedInstance].people increment:@"open_count"
                                             by:@(1)];
    [[Mixpanel sharedInstance] registerSuperProperties:@{@"is_staff": (self.staffValue) ? @"true" : @"false"}];
    [[Mixpanel sharedInstance] registerSuperProperties:@{@"is_pro": (self.professionalValue) ? @"true" : @"false"}];
}

- (void)API_updateImage {
    self.isUploading = @YES;

    //  If presignedUpload returned, use it, otherwise fallback to old upload method
    if (self.presignedUpload) {
        [self S3_updateImage];
    } else {
        [self API_prepareAndUploadPresignedUpload];
    }
}

- (void)API_prepareAndUploadPresignedUpload {
    __weak __typeof(self)weakSelf = self;
    [_appDelegate.apiService getUserProfile:self
                                 parameters:@{ @"prepare_presigned_upload": @"true" }
                                    success:^(id responseObject) {
                                        if (weakSelf) [weakSelf S3_updateImage];
                                    } failure:^(NSError *error) {
                                        [_appDelegate.apiService updateUserImage:weakSelf
                                                                         success:^(id responseObject) {
                                                                             if (weakSelf) weakSelf.isUploading = @NO;
                                                                         } failure:nil];
                                    }];
}

- (void)S3_updateImage {
    __weak __typeof(self)weakSelf = self;
    [_appDelegate.s3Service uploadImageData:self.profilePhotoFull
                         forPresignedUpload:self.presignedUpload
                                    success:^(NSDictionary *responseDictionary) {
                                        [_appDelegate.apiService updatePhotoKey:responseDictionary[@"Key"]
                                                                        forUser:weakSelf
                                                                        success:^(id responseObject) {
                                                                            if (weakSelf) {
                                                                                [weakSelf.presignedUpload MR_deleteEntity];
                                                                                [weakSelf.presignedUpload.managedObjectContext MR_saveToPersistentStoreAndWait];
                                                                                weakSelf.isUploading = @NO;
                                                                            }
                                                                        } failure:nil];
                                    } failure:^(NSError *error) {
                                        //  S3 upload failed, fallback to API upload
                                        [_appDelegate.apiService updateUserImage:weakSelf
                                                                         success:^(id responseObject) {
                                                                             if (weakSelf) weakSelf.isUploading = @NO;
                                                                         } failure:nil];
                                    }];
}

- (NSString *)fullName {
    return ([MRSLUser isCurrentUserGuest]) ? @"Guest" : ([NSString stringWithFormat:@"%@ %@", self.first_name ? : @"", self.last_name ? : @""]);
}

- (NSString *)displayName {
    return [NSString stringWithFormat:@"%@ (%@)", [self fullName], [self username]];
}

- (NSString *)fullNameOrTwitterHandle {
    return (self.twitter_username) ? [NSString stringWithFormat:@"@%@", self.twitter_username] : self.fullName;
}

- (NSURLRequest *)imageURLRequestForImageSizeType:(MRSLImageSizeType)type {
    if (!self.profilePhotoURL) return nil;

    BOOL isRetina = ([UIScreen mainScreen].scale == 2.f);

    NSString *typeSizeString = nil;

    switch (type) {
        case MRSLImageSizeTypeSmall:
            typeSizeString = (isRetina) ? MRSLProfileImageLargeRetinaKey : MRSLProfileImageLargeKey;
            break;
        case MRSLImageSizeTypeLarge:
            typeSizeString = (isRetina) ? MRSLProfileImageSmallRetinaKey : MRSLProfileImageSmallKey;
            break;
        default:
            DDLogError(@"Unsupported Profile Image Size Type Requested!");
            return nil;
            break;
    }

    NSString *adjustedURLForType = [self.profilePhotoURL stringByReplacingOccurrencesOfString:MRSLImageSizeKey
                                                                                   withString:typeSizeString];
    return [NSURLRequest requestWithURL:[NSURL URLWithString:adjustedURLForType]];
}

- (NSData *)localImageLarge {
    return self.profilePhotoLarge;
}

- (NSData *)localImageSmall {
    return self.profilePhotoThumb;
}

- (NSString *)imageURL {
    return self.profilePhotoURL;
}

- (NSString *)reportableUrlString {
    return [NSString stringWithFormat:@"users/%i/report", self.userIDValue];
}

- (void)API_reportWithSuccess:(MRSLSuccessBlock)successOrNil
                      failure:(MRSLFailureBlock)failureOrNil {
    if ([MRSLUser isCurrentUserGuest]) return;
    [_appDelegate.apiService sendReportable:self
                                    success:successOrNil
                                    failure:failureOrNil];
}

#pragma mark - MagicalRecord

- (void)didImport:(id)data {
    if (![data[@"photos"] isEqual:[NSNull null]] && !self.photo_processingValue && !self.isUploadingValue) {
        NSDictionary *photoDictionary = data[@"photos"];
        self.profilePhotoURL = [photoDictionary[@"_40x40"] stringByReplacingOccurrencesOfString:@"_40x40"
                                                                                     withString:@"IMAGE_SIZE"];
    }
    if (![data[@"followed_at"] isEqual:[NSNull null]]) {
        NSString *dateString = data[@"followed_at"];
        self.dateFollowed = [_appDelegate.defaultDateFormatter dateFromString:dateString];
    }
    if (![data[@"settings"] isEqual:[NSNull null]]) {
        if (![data[@"settings"][@"auto_follow"] isEqual:[NSNull null]]) {
            self.auto_follow = @([data[@"settings"][@"auto_follow"] boolValue]);
        }
    }

    if (self.photo_processingValue || self.profilePhotoURL) self.isUploading = @NO;
}

- (NSString *)jsonKeyName {
    return @"user";
}

- (NSDictionary *)objectToJSON {
    NSMutableDictionary *objectInfoJSON = [NSMutableDictionary dictionary];
    if (self.first_name) objectInfoJSON[@"first_name"] = self.first_name;
    if (self.last_name) objectInfoJSON[@"last_name"] = self.last_name;
    if (self.bio) objectInfoJSON[@"bio"] = self.bio;
    if (self.professionalValue) objectInfoJSON[@"professional"] = self.professional;
    return objectInfoJSON;
}

@end
