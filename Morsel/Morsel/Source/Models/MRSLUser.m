#import "MRSLUser.h"

#import <AFNetworking/AFNetworking.h>

#import "ModelController.h"

@interface MRSLUser ()

@end


@implementation MRSLUser

#pragma mark - Instance Methods

- (void)setWithDictionary:(NSDictionary *)dictionary
                inContext:(NSManagedObjectContext *)contextOrNil
{
    self.emailAddress = ([dictionary[@"email"] isEqual:[NSNull null]]) ? self.emailAddress : dictionary[@"email"];
    self.firstName = ([dictionary[@"first_name"] isEqual:[NSNull null]]) ? self.firstName : dictionary[@"first_name"];
    self.lastName = ([dictionary[@"last_name"] isEqual:[NSNull null]]) ? self.lastName : dictionary[@"last_name"];
    self.occupationTitle = ([dictionary[@"title"] isEqual:[NSNull null]]) ? self.occupationTitle : dictionary[@"title"];
    self.authToken = ([dictionary[@"auth_token"] isEqual:[NSNull null]]) ? self.authToken : dictionary[@"auth_token"];
    
    if (![dictionary[@"photos"] isEqual:[NSNull null]])
    {
        NSDictionary *photoDictionary = dictionary[@"photos"];
        
        self.profileImageURL = [photoDictionary[@"_40x40"] stringByReplacingOccurrencesOfString:@"_40x40"
                                                                                   withString:@"IMAGE_SIZE"];
    }
    
    
    self.userID = ([dictionary[@"id"] isEqual:[NSNull null]]) ? self.userID : [NSNumber numberWithInt:[dictionary[@"id"] intValue]];
    
    if (contextOrNil)
    {
        // Only used when creation of MO children is relevant
    }
}

- (BOOL)isCurrentUser
{
    return ([[ModelController sharedController].currentUser.userID intValue] == [self.userID intValue]);
}

- (UserOccupationType)occupationTypeRaw
{
    return (UserOccupationType)[self.occupationType intValue];
}

- (NSURLRequest *)userProfilePictureURLRequestForImageSizeType:(ProfileImageSizeType)type
{
    if (!self.profileImageURL) return nil;
    
    BOOL isRetina = ([UIScreen mainScreen].scale == 2.f);
    
    NSString *typeSizeString = nil;
    
    switch (type)
    {
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

- (NSString *)fullName
{
    return [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
}

- (void)addPost:(MRSLPost *)post
{
    [self.postsSet addObject:post];
}

- (void)setOccupationTypeRaw:(UserOccupationType)type
{
    [self setOccupationType:[NSNumber numberWithInt:type]];
}

#pragma mark - Private Methods

+(NSSet *)keyPathsForValuesAffectingOccupationTypeRaw
{
    return [NSSet setWithObject:@"occupationType"];
}

@end
