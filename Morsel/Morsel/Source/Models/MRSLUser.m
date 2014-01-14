#import "MRSLUser.h"

#import <AFNetworking/AFNetworking.h>

@interface MRSLUser ()

@end


@implementation MRSLUser

#pragma mark - Instance Methods

- (void)setWithDictionary:(NSDictionary *)dictionary
                inContext:(NSManagedObjectContext *)contextOrNil
                  success:(MorselModelSuccessBlock)successOrNil
                  failure:(MorselModelFailureBlock)failureOrNil
{
    self.emailAddress = ([dictionary[@"email"] isEqual:[NSNull null]]) ? self.emailAddress : dictionary[@"email"];
    self.firstName = ([dictionary[@"first_name"] isEqual:[NSNull null]]) ? self.firstName : dictionary[@"first_name"];
    self.lastName = ([dictionary[@"last_name"] isEqual:[NSNull null]]) ? self.lastName : dictionary[@"last_name"];
    self.occupationTitle = ([dictionary[@"title"] isEqual:[NSNull null]]) ? self.occupationTitle : dictionary[@"title"];
    self.authToken = ([dictionary[@"auth_token"] isEqual:[NSNull null]]) ? self.authToken : dictionary[@"auth_token"];
    self.profileImageURL = ([dictionary[@"photo_url"] isEqual:[NSNull null]]) ? self.profileImageURL : dictionary[@"photo_url"];
    self.userID = ([dictionary[@"id"] isEqual:[NSNull null]]) ? self.userID : [NSNumber numberWithInt:[dictionary[@"id"] intValue]];
    
    [self retrieveProfileImageWithSuccess:nil
                             failure:nil];
    
    if (contextOrNil)
    {
        NSNumber *userID = [self.userID copy];
        
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [contextOrNil MR_saveOnlySelfWithCompletion:^(BOOL success, NSError *error)
             {
                 if (error)
                 {
                     if (failureOrNil)
                     {
                         failureOrNil(error);
                     }
                 }
                 else
                 {
                     if (successOrNil)
                     {
                         successOrNil(userID);
                     }
                 }
             }];
        });
    }
}

- (NSString *)fullName
{
    return [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
}

- (UserOccupationType)occupationTypeRaw
{
    return (UserOccupationType)[self.occupationType intValue];
}

- (void)addPost:(MRSLPost *)post
{
    [self.postsSet addObject:post];
}


- (void)retrieveProfileImageWithSuccess:(MorselImageDownloadSuccessBlock)successOrNil
                                failure:(MorselImageDownloadFailureBlock)failureOrNil
{
    if (!self.profileImageURL)
    {
        NSError *imageUrlFailure = [NSError errorWithDomain:@"com.eatmorsel.morsel" code:50 userInfo:@{@"error": @"No image URL available"}];
        
        if (failureOrNil) failureOrNil(imageUrlFailure);
        
        return;
    }
    
    if (!self.profileImage)
    {
        AFHTTPRequestOperation *imageRequestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.profileImageURL]]];
        [imageRequestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, NSData *imageData)
         {
             self.profileImage = imageData;
             
             UIImage *downloadedProfileImage = [UIImage imageWithData:imageData];
             
             if (successOrNil)
             {
                 successOrNil(downloadedProfileImage);
             }
         }
                                                     failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             if (failureOrNil)
             {
                 failureOrNil(error);
             }
         }];
        [imageRequestOperation start];
    }
    
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
