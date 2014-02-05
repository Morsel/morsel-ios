#import "MRSLUser.h"

#import <AFNetworking/AFNetworking.h>

#import "ModelController.h"

@interface MRSLUser ()

@end

@implementation MRSLUser

#pragma mark - Class Methods

+ (void)createOrUpdateUserFromResponseObject:(id)responseObject shouldPostNotification:(BOOL)shouldPostNotifications {
    NSNumber *userID = [NSNumber numberWithInt:[responseObject[@"data"][@"id"] intValue]];

    MRSLUser *existingUser = [[ModelController sharedController] userWithID:userID];

    if (existingUser) {
        DDLogDebug(@"User existed on device. Updating information.");

        [existingUser setWithDictionary:responseObject[@"data"]];

        [[NSUserDefaults standardUserDefaults] setObject:existingUser.userID
                                                  forKey:@"userID"];
        [[NSUserDefaults standardUserDefaults] synchronize];

        if (shouldPostNotifications) [[NSNotificationCenter defaultCenter] postNotificationName:MRSLServiceDidLogInUserNotification
                                                                                         object:nil];
    } else {
        DDLogDebug(@"User did not exist on device. Creating new.");

        MRSLUser *user = [MRSLUser MR_createInContext:[ModelController sharedController].defaultContext];
        [user setWithDictionary:responseObject[@"data"]];

        [[NSUserDefaults standardUserDefaults] setObject:user.userID
                                                  forKey:@"userID"];
        [[NSUserDefaults standardUserDefaults] synchronize];

        if (shouldPostNotifications) [[NSNotificationCenter defaultCenter] postNotificationName:MRSLServiceDidLogInUserNotification
                                                                                         object:nil];
    }
}

#pragma mark - Instance Methods

- (void)setWithDictionary:(NSDictionary *)dictionary {
    self.userName = ([dictionary[@"username"] isEqual:[NSNull null]]) ? self.userName : dictionary[@"username"];
    self.emailAddress = ([dictionary[@"email"] isEqual:[NSNull null]]) ? self.emailAddress : dictionary[@"email"];
    self.firstName = ([dictionary[@"first_name"] isEqual:[NSNull null]]) ? self.firstName : dictionary[@"first_name"];
    self.lastName = ([dictionary[@"last_name"] isEqual:[NSNull null]]) ? self.lastName : dictionary[@"last_name"];
    self.occupationTitle = ([dictionary[@"title"] isEqual:[NSNull null]]) ? self.occupationTitle : dictionary[@"title"];
    self.authToken = ([dictionary[@"auth_token"] isEqual:[NSNull null]]) ? self.authToken : dictionary[@"auth_token"];
    self.morselCount = ([dictionary[@"morsel_count"] isEqual:[NSNull null]]) ? self.morselCount : [NSNumber numberWithInt:[dictionary[@"morsel_count"] intValue]];
    self.likeCount = ([dictionary[@"like_count"] isEqual:[NSNull null]]) ? self.likeCount : [NSNumber numberWithInt:[dictionary[@"like_count"] intValue]];
    self.twitterUsername = ([dictionary[@"twitter_username"] isEqual:[NSNull null]]) ? self.twitterUsername : dictionary[@"twitter_username"];
    self.facebookUID = ([dictionary[@"facebook_uid"] isEqual:[NSNull null]]) ? self.facebookUID : dictionary[@"facebook_uid"];

    if (![dictionary[@"photos"] isEqual:[NSNull null]]) {
        NSDictionary *photoDictionary = dictionary[@"photos"];

        self.profileImageURL = [photoDictionary[@"_40x40"] stringByReplacingOccurrencesOfString:@"_40x40"
                                                                                     withString:@"IMAGE_SIZE"];
    }

    self.userID = ([dictionary[@"id"] isEqual:[NSNull null]]) ? self.userID : [NSNumber numberWithInt:[dictionary[@"id"] intValue]];
}

- (BOOL)isCurrentUser {
    return ([[ModelController sharedController].currentUser.userID intValue] == [self.userID intValue]);
}

- (UserOccupationType)occupationTypeRaw {
    return (UserOccupationType)[self.occupationType intValue];
}

- (NSURLRequest *)userProfilePictureURLRequestForImageSizeType:(ProfileImageSizeType)type {
    if (!self.profileImageURL) return nil;

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

    NSString *adjustedURLForType = [self.profileImageURL stringByReplacingOccurrencesOfString:@"IMAGE_SIZE"
                                                                                   withString:typeSizeString];

    return [NSURLRequest requestWithURL:[NSURL URLWithString:adjustedURLForType]];
}

- (NSString *)fullName {
    return [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
}

- (void)addPost:(MRSLPost *)post {
    [self.postsSet addObject:post];
}

- (void)setOccupationTypeRaw:(UserOccupationType)type {
    [self setOccupationType:[NSNumber numberWithInt:type]];
}

#pragma mark - Private Methods

+ (NSSet *)keyPathsForValuesAffectingOccupationTypeRaw {
    return [NSSet setWithObject:@"occupationType"];
}

@end
