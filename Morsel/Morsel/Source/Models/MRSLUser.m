#import "MRSLUser.h"

#import "MRSLS3Service.h"
#import "MRSLAPIService+Profile.h"
#import "MRSLAPIService+Notifications.h"
#import "MRSLAPIService+Report.h"

#import "MRSLPresignedUpload.h"

static const int kGuestUserID = -1;

@implementation MRSLUser

#pragma mark - Additions

+ (NSString *)API_identifier {
    return MRSLUserAttributes.userID;
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

#pragma mark - Class Methods

+ (BOOL)currentUserOwnsMorselWithCreatorID:(int)creatorID {
    return ([MRSLUser currentUser].userIDValue == creatorID);
}

+ (BOOL)isCurrentUserGuest {
    return [[self currentUser] isGuestUser];
}

+ (NSString *)apiTokenForCurrentUser {
    MRSLUser *currentUser = [MRSLUser currentUser];

    return [NSString stringWithFormat:@"%i:%@", currentUser.userIDValue, currentUser.auth_token];
}

+ (MRSLUser *)currentUser {
    NSNumber *currentUserID = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"userID"];
    MRSLUser *currentUser = nil;
    if (currentUserID) {
        currentUser = [MRSLUser MR_findFirstByAttribute:MRSLUserAttributes.userID
                                              withValue:currentUserID
                                              inContext:[NSManagedObjectContext MR_defaultContext]];
    }
    return currentUser;
}

+ (MRSLUser *)createOrUpdateUserFromResponseObject:(id)userDictionary
                                      existingUser:(BOOL)existingUser {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"userID"] != nil) [_appDelegate resetDataStore];
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
                                                                          object:@YES];

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

    [user setThirdPartySettings];

    [[NSUserDefaults standardUserDefaults] setObject:user.userID
                                              forKey:@"userID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [user.managedObjectContext MR_saveToPersistentStoreAndWait];

    [[NSNotificationCenter defaultCenter] postNotificationName:MRSLServiceDidLogInGuestNotification
                                                        object:nil];
    return user;
}

+ (void)updateCurrentUserToProfessional {
    [_appDelegate.apiService updateCurrentUserToProfessional:YES
                                                     success:nil
                                                     failure:nil];
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

+ (void)API_updateNotificationsAmount:(MRSLAPICountBlock)amountOrNil
                              failure:(MRSLFailureBlock)failureOrNil {
    if ([MRSLUser isCurrentUserGuest]) return;
    if (![MRSLUser currentUser]) {
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        return;
    }
    [_appDelegate.apiService getUnreadCountWithSuccess:^(int countValue) {
        if (amountOrNil) amountOrNil(countValue);
    } failure:failureOrNil];
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

#pragma mark - Instance Methods

- (BOOL)isCurrentUser {
    NSNumber *currentUserID = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"userID"];
    return ([currentUserID intValue] == self.userIDValue);
}

- (BOOL)isGuestUser {
    return (self.userIDValue == kGuestUserID);
}

- (BOOL)hasEmptyName {
    return !self.first_name && !self.last_name;
}

- (BOOL)isProfessional {
    return self.professionalValue;
}

- (CGFloat)profileInformationHeight {
    CGFloat infoHeight = 0.f;
    NSMutableAttributedString *attributedInfo = [self profileInformation];
    CGRect infoRect = [attributedInfo boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - (MRSLCellDefaultPadding * 2), CGFLOAT_MAX)
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                   context:nil];
    infoHeight = infoRect.size.height + 40.f;
    return MAX(75.f, infoHeight);
}

- (NSString *)fullName {
    if ([self isGuestUser]) {
        return @"Guest";
    } else if ([self hasEmptyName]) {
        return MRSLDefaultEmptyUserName;
    } else {
        return [NSString stringWithFormat:@"%@ %@", self.first_name ? : @"", self.last_name ? : @""];
    }
}

- (NSString *)displayName {
    return [NSString stringWithFormat:@"%@ (%@)", [self fullName], [self username]];
}

- (NSString *)fullNameOrTwitterHandle {
    return (self.twitter_username) ? [NSString stringWithFormat:@"@%@", self.twitter_username] : self.fullName;
}

- (NSURLRequest *)imageURLRequestForImageSizeType:(MRSLImageSizeType)type {
    if (!self.profilePhotoURL) return nil;

    BOOL isRetinaOrIpad = ([UIScreen mainScreen].scale == 2.f || [UIDevice currentDeviceIsIpad]);

    NSString *typeSizeString = nil;

    switch (type) {
        case MRSLImageSizeTypeSmall:
            typeSizeString = (isRetinaOrIpad) ? MRSLProfileImageLargeRetinaKey : MRSLProfileImageLargeKey;
            break;
        case MRSLImageSizeTypeLarge:
            typeSizeString = (isRetinaOrIpad) ? MRSLProfileImageSmallRetinaKey : MRSLProfileImageSmallKey;
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

- (void)setThirdPartySettings {
    if ([MRSLUser isCurrentUserGuest]) {
        [[Mixpanel sharedInstance] registerSuperProperties:@{@"is_guest": @"true"}];
    } else if ([MRSLUser currentUser] && ![MRSLUser isCurrentUserGuest]) {
        NSString *idString = [NSString stringWithFormat:@"%i", self.userIDValue];
#if defined (ROLLBAR_ENVIRONMENT)
        [[Rollbar currentConfiguration] setPersonId:idString
                                           username:self.username
                                              email:nil];
#endif
        [[Mixpanel sharedInstance] identify:idString];
        NSMutableDictionary *userProperties = [NSMutableDictionary dictionaryWithDictionary:@{@"first_name": NSNullIfNil(self.first_name),
                                                                                              @"last_name": NSNullIfNil(self.last_name),
                                                                                              @"created_at": NSNullIfNil(self.creationDate),
                                                                                              @"username": NSNullIfNil(self.username)}];
        if (self.email) {
            [userProperties setObject:self.email
                               forKey:@"$email"];
        }
        [[Mixpanel sharedInstance].people set:userProperties];
        [[Mixpanel sharedInstance].people increment:@"open_count"
                                                 by:@(1)];
        [[Mixpanel sharedInstance] registerSuperProperties:@{@"is_staff": (self.staffValue) ? @"true" : @"false"}];
        [[Mixpanel sharedInstance] registerSuperProperties:@{@"is_pro": (self.professionalValue) ? @"true" : @"false"}];
        [[Mixpanel sharedInstance] registerSuperProperties:@{@"is_guest": @"false"}];
    }
}

- (NSMutableAttributedString *)profileInformation {
    NSString *fullName = [self fullName];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ \n%@", fullName, self.bio ?: @""]
                                                                                         attributes:@{NSFontAttributeName : [UIFont preferredRobotoFontForTextStyle:UIFontTextStyleBody]}];
    [attributedString addAttribute:NSLinkAttributeName
                             value:@"profile://display"
                             range:[[attributedString string] rangeOfString:fullName]];
    [attributedString addAttribute:NSFontAttributeName
                             value:[UIFont preferredRobotoFontForTextStyle:UIFontTextStyleHeadline]
                             range:[[attributedString string] rangeOfString:fullName]];

    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    [attributedString addAttribute:NSParagraphStyleAttributeName
                             value:paragraphStyle
                             range:NSMakeRange(0, attributedString.length)];
    return attributedString;
}

#pragma mark - MRSLImageRequestable

- (NSData *)localImageLarge {
    return self.profilePhotoLarge;
}

- (NSData *)localImageSmall {
    return self.profilePhotoThumb;
}

- (NSString *)imageURL {
    return self.profilePhotoURL;
}

#pragma mark - MRSLReportable

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

#pragma mark - API

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

@end
