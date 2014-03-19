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
                      shouldPostNotification:(BOOL)shouldPostNotifications {
    NSNumber *userID = @([userDictionary[@"id"] intValue]);

    MRSLUser *user = [MRSLUser MR_findFirstByAttribute:MRSLUserAttributes.userID
                                             withValue:userID
                                             inContext:[NSManagedObjectContext MR_defaultContext]];

    if (!user) {
        DDLogDebug(@"User did not exist on device. Creating new.");
        user = [MRSLUser MR_createInContext:[NSManagedObjectContext MR_defaultContext]];
    } else {
        DDLogDebug(@"User existed on device. Updating information.");
    }

    [user MR_importValuesForKeysWithObject:userDictionary];

    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel identify:[NSString stringWithFormat:@"%i", user.userIDValue]];
    [mixpanel.people set:@{@"first_name": NSNullIfNil(user.first_name),
                           @"last_name": NSNullIfNil(user.last_name),
                           @"created_at": NSNullIfNil(userDictionary[@"created_at"]),
                           @"title": NSNullIfNil(user.title),
                           @"username": NSNullIfNil(user.username)}];
    [mixpanel.people increment:@"open_count"
                            by:@(1)];

    [[NSUserDefaults standardUserDefaults] setObject:user.userID
                                              forKey:@"userID"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    if (shouldPostNotifications) [[NSNotificationCenter defaultCenter] postNotificationName:MRSLServiceDidLogInUserNotification
                                                                                     object:nil];
}

#pragma mark - Instance Methods

- (BOOL)isCurrentUser {
    NSNumber *currentUserID = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"userID"];
    return ([currentUserID intValue] == self.userIDValue);
}

- (BOOL)shouldTrack {
    // This still allows anonymous tracking to appear before a user signs in
    return !(!self.title || self.title.length == 0);
}

- (NSString *)fullName {
    return [NSString stringWithFormat:@"%@ %@", self.first_name, self.last_name];
}

- (NSURLRequest *)userProfilePictureURLRequestForImageSizeType:(ProfileImageSizeType)type {
    if (!self.profilePhotoURL) return nil;

    BOOL isRetina = ([UIScreen mainScreen].scale == 2.f);

    NSString *typeSizeString = nil;

    switch (type) {
        case ProfileImageSizeTypeSmall:
            typeSizeString = (isRetina) ? @"_80x80" : @"_40x40";
            break;
        case ProfileImageSizeTypeMedium:
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

    [self.managedObjectContext MR_saveToPersistentStoreWithCompletion:nil];
}

- (NSDictionary *)objectToJSON {
    NSMutableDictionary *objectInfoJSON = [NSMutableDictionary dictionary];

    if (self.email) [objectInfoJSON setObject:self.email
                                       forKey:@"email"];
    if (self.username) [objectInfoJSON setObject:self.username
                                          forKey:@"username"];
    if (self.first_name) [objectInfoJSON setObject:self.first_name
                                            forKey:@"first_name"];
    if (self.last_name) [objectInfoJSON setObject:self.last_name
                                           forKey:@"last_name"];
    if (self.title) [objectInfoJSON setObject:self.title
                                       forKey:@"title"];
    if (self.bio) [objectInfoJSON setObject:self.bio
                                     forKey:@"bio"];

    NSMutableDictionary *userJSON = [NSMutableDictionary dictionaryWithObject:objectInfoJSON
                                                                       forKey:@"user"];
    
    return userJSON;
}

@end
