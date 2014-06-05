#import "MRSLUser.h"

#import <AFNetworking/AFNetworking.h>

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

    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel identify:[NSString stringWithFormat:@"%i", user.userIDValue]];
    [mixpanel.people set:@{@"first_name": NSNullIfNil(user.first_name),
                           @"last_name": NSNullIfNil(user.last_name),
                           @"created_at": NSNullIfNil(userDictionary[@"created_at"]),
                           @"username": NSNullIfNil(user.username)}];
    [mixpanel.people increment:@"open_count"
                            by:@(1)];

    [[NSUserDefaults standardUserDefaults] setObject:user.userID
                                              forKey:@"userID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];

    if (shouldMorselNotifications) [[NSNotificationCenter defaultCenter] postNotificationName:MRSLServiceDidLogInUserNotification
                                                                                     object:nil];
}

+(NSSet *)keyPathsForValuesAffectingIndustryTypeEnum {
    return [NSSet setWithObject:@"industryType"];
}

#pragma mark - Instance Methods

- (BOOL)isCurrentUser {
    NSNumber *currentUserID = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"userID"];
    return ([currentUserID intValue] == self.userIDValue);
}

- (BOOL)isChef {
    return (self.industryTypeEnum == MRSLIndustryTypeChef);
}

- (BOOL)shouldTrack {
    // This still allows anonymous tracking to appear before a user signs in
    return !self.staffValue;
}

- (MRSLIndustryType)industryTypeEnum {
    return (MRSLIndustryType)[self industryTypeValue];
}

- (void)setIndustryTypeEnum:(MRSLIndustryType)type {
    [self setIndustryType:[NSNumber numberWithInt:type]];
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

- (NSString *)industryTypeName {
    switch (self.industryTypeEnum) {
        case MRSLIndustryTypeChef:
            return @"chef";
            break;
        case MRSLIndustryTypeMedia:
            return @"media";
            break;
        case MRSLIndustryTypeDiner:
            return @"diner";
            break;
        default:
            break;
    }
}

- (NSURLRequest *)userProfilePictureURLRequestForImageSizeType:(MRSLProfileImageSizeType)type {
    if (!self.profilePhotoURL) return nil;

    BOOL isRetina = ([UIScreen mainScreen].scale == 2.f);

    NSString *typeSizeString = nil;

    switch (type) {
        case MRSLProfileImageSizeTypeSmall:
            typeSizeString = (isRetina) ? @"_80x80" : @"_40x40";
            break;
        case MRSLProfileImageSizeTypeMedium:
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

#pragma mark - MagicalRecord

- (void)didImport:(id)data {
    if (![data[@"photos"] isEqual:[NSNull null]]) {
        NSDictionary *photoDictionary = data[@"photos"];
        self.profilePhotoURL = [photoDictionary[@"_40x40"] stringByReplacingOccurrencesOfString:@"_40x40"
                                                                                     withString:@"IMAGE_SIZE"];
    }
    if (![data[@"settings"] isEqual:[NSNull null]]) {
        if (![data[@"auto_follow"] isEqual:[NSNull null]]) {
            self.auto_follow = @([data[@"auto_follow"] boolValue]);
        }
    }
    if (![data[@"industry"] isEqual:[NSNull null]]) {
        NSString *industry = data[@"industry"];
        if ([industry isEqualToString:@"chef"]) {
            self.industryType = @(MRSLIndustryTypeChef);
        } else if ([industry isEqualToString:@"media"]) {
            self.industryType = @(MRSLIndustryTypeMedia);
        } else {
            self.industryType = @(MRSLIndustryTypeDiner);
        }
    }
    if (self.profilePhotoFull) self.profilePhotoFull = nil;
}

- (NSDictionary *)objectToJSON {
    NSMutableDictionary *objectInfoJSON = [NSMutableDictionary dictionary];

    if (self.first_name) [objectInfoJSON setObject:self.first_name
                                            forKey:@"first_name"];
    if (self.last_name) [objectInfoJSON setObject:self.last_name
                                           forKey:@"last_name"];
    if (self.bio) [objectInfoJSON setObject:self.bio
                                     forKey:@"bio"];

    NSMutableDictionary *userJSON = [NSMutableDictionary dictionaryWithObject:objectInfoJSON
                                                                       forKey:@"user"];
    
    return userJSON;
}

@end
