#import "MRSLUser.h"

#import "MRSLAPIService+Profile.h"

@interface MRSLUser ()

@end

@implementation MRSLUser

#pragma mark - Class Methods

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

+ (void)refreshCurrentUserWithSuccess:(MRSLAPISuccessBlock)userSuccessOrNil failure:(MRSLFailureBlock)failureOrNil {
    [_appDelegate.apiService getUserProfile:[MRSLUser currentUser]
                                    success:userSuccessOrNil
                                    failure:failureOrNil];
}

+ (void)createOrUpdateUserFromResponseObject:(id)userDictionary
                      shouldMorselNotification:(BOOL)shouldMorselNotifications {
    NSNumber *userID = @([userDictionary[@"id"] intValue]);

    MRSLUser *user = [MRSLUser MR_findFirstByAttribute:MRSLUserAttributes.userID
                                             withValue:userID
                                             inContext:[NSManagedObjectContext MR_defaultContext]];
    if (!user) {
        DDLogDebug(@"User did not exist on device. Creating new.");
        user = [MRSLUser MR_createInContext:[NSManagedObjectContext MR_defaultContext]];
    }

    [user MR_importValuesForKeysWithObject:userDictionary];

    [user setThirdPartySettings];

    [[NSUserDefaults standardUserDefaults] setObject:user.userID
                                              forKey:@"userID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];

    if (shouldMorselNotifications) [[NSNotificationCenter defaultCenter] postNotificationName:MRSLServiceDidLogInUserNotification
                                                                                     object:nil];
}

+ (void)updateCurrentUserToProfessional {
    [_appDelegate.apiService updateCurrentUserToProfessional:YES
                                                     success:nil
                                                     failure:nil];
}

+ (void)resetThirdPartySettings {
    [[Rollbar currentConfiguration] setPersonId:nil
                                       username:nil
                                          email:nil];

    [[Mixpanel sharedInstance] identify:nil];
}

#pragma mark - Instance Methods

- (BOOL)isCurrentUser {
    NSNumber *currentUserID = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"userID"];
    return ([currentUserID intValue] == self.userIDValue);
}

- (BOOL)isProfessional {
    return self.professionalValue;
}

- (BOOL)shouldTrack {
    // This still allows anonymous tracking to appear before a user signs in
    return !self.staffValue;
}

- (void)setThirdPartySettings {
    NSString *idString = [NSString stringWithFormat:@"%i", self.userIDValue];
    [[Rollbar currentConfiguration] setPersonId:idString
                                       username:self.username
                                          email:nil];

    [[Mixpanel sharedInstance] identify:idString];
}

- (NSString *)fullName {
    return [NSString stringWithFormat:@"%@ %@", self.first_name, self.last_name];
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
            typeSizeString = (isRetina) ? @"_80x80" : @"_40x40";
            break;
        case MRSLImageSizeTypeLarge:
            typeSizeString = (isRetina) ? @"_144x144" : @"_72x72";
            break;
        default:
            DDLogError(@"Unsupported Profile Image Size Type Requested!");
            return nil;
            break;
    }

    NSString *adjustedURLForType = [self.profilePhotoURL stringByReplacingOccurrencesOfString:@"IMAGE_SIZE"
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

#pragma mark - MagicalRecord

- (void)didImport:(id)data {
    if (![data[@"photos"] isEqual:[NSNull null]]) {
        NSDictionary *photoDictionary = data[@"photos"];
        self.profilePhotoURL = [photoDictionary[@"_40x40"] stringByReplacingOccurrencesOfString:@"_40x40"
                                                                                     withString:@"IMAGE_SIZE"];
    }
    if (![data[@"settings"] isEqual:[NSNull null]]) {
        if (![data[@"settings"][@"auto_follow"] isEqual:[NSNull null]]) {
            self.auto_follow = @([data[@"settings"][@"auto_follow"] boolValue]);
        }
    }
    if (self.profilePhotoFull) self.profilePhotoFull = nil;
}

- (NSString *)jsonKeyName {
    return @"user";
}

- (NSDictionary *)objectToJSON {
    NSMutableDictionary *objectInfoJSON = [NSMutableDictionary dictionary];

    if (self.first_name) [objectInfoJSON setObject:self.first_name
                                            forKey:@"first_name"];
    if (self.last_name) [objectInfoJSON setObject:self.last_name
                                           forKey:@"last_name"];
    if (self.bio) [objectInfoJSON setObject:self.bio
                                     forKey:@"bio"];

    if (self.professionalValue) [objectInfoJSON setObject:self.professional
                                                   forKey:@"professional"];
    return objectInfoJSON;
}

@end
