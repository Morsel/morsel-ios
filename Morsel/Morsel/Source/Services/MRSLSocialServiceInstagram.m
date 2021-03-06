//
//  MRSLSocialServiceInstagram.m
//  Morsel
//
//  Created by Javier Otero on 5/21/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLSocialServiceInstagram.h"

#import "MRSLAPIService+Authentication.h"

#import "MRSLSocialAuthentication.h"

#import "MRSLUser.h"

@interface MRSLSocialServiceInstagram ()
<UIAlertViewDelegate>

@property (nonatomic) BOOL clearingSocialAuthentication;

@property (strong, nonatomic) MRSLSocialSuccessBlock instagramSuccessBlock;
@property (strong, nonatomic) MRSLSocialFailureBlock instagramFailureBlock;

@property (strong, nonatomic) NSArray *friendUIDs;
@property (strong, nonatomic) NSDictionary *userInfo;

@end

@implementation MRSLSocialServiceInstagram

+ (instancetype)sharedService {
    static MRSLSocialServiceInstagram *_sharedService = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _sharedService = [[MRSLSocialServiceInstagram alloc] init];
    });
    return _sharedService;
}

- (id)init {
    self = [super init];
    if (self) {
        [[NXOAuth2AccountStore sharedStore] setClientID:INSTAGRAM_CONSUMER_KEY
                                                 secret:INSTAGRAM_CONSUMER_SECRET
                                       authorizationURL:[NSURL URLWithString:@"https://api.instagram.com/oauth/authorize"]
                                               tokenURL:[NSURL URLWithString:@"https://api.instagram.com/oauth/access_token"]
                                            redirectURL:[NSURL URLWithString:INSTAGRAM_CALLBACK]
                                         forAccountType:MRSLInstagramAccountTypeKey];
        self.oauth2Client = [AFOAuth2Client clientWithBaseURL:[NSURL URLWithString:@"https://api.instagram.com/"]
                                                     clientID:INSTAGRAM_CONSUMER_KEY
                                                       secret:INSTAGRAM_CONSUMER_SECRET];
    }
    return self;
}

#pragma mark - Authentication Methods

- (void)authenticateWithInstagramWithSuccess:(MRSLSocialSuccessBlock)successOrNil
                                     failure:(MRSLSocialFailureBlock)failureOrNil {
    [[NXOAuth2AccountStore sharedStore] requestAccessToAccountWithType:MRSLInstagramAccountTypeKey];

    self.instagramSuccessBlock = successOrNil;
    self.instagramFailureBlock = failureOrNil;
}

- (void)completeAuthenticationWithCode:(NSString *)code {
    [_oauth2Client authenticateUsingOAuthWithURLString:@"https://api.instagram.com/oauth/access_token"
                                                  code:code
                                           redirectURI:INSTAGRAM_CALLBACK
                                               success:^(AFOAuthCredential *credential) {
                                                   DDLogDebug(@"Instagram accessToken: %@", credential.accessToken);
                                                   if (credential.accessToken) {
                                                       MRSLSocialAuthentication *socialAuthentication = [[MRSLSocialAuthentication alloc] init];
                                                       socialAuthentication.provider = @"instagram";
                                                       socialAuthentication.token = credential.accessToken;
                                                       socialAuthentication.tokenType = credential.tokenType;
                                                       socialAuthentication.username = credential.authorizationResponse[@"user"][@"username"];
                                                       socialAuthentication.uid = credential.authorizationResponse[@"user"][@"id"];
                                                       self.instagramCredentials = credential;
                                                       [self restoreInstagramWithAuthentication:socialAuthentication
                                                                                   shouldCreate:YES];
                                                       if (_instagramSuccessBlock) _instagramSuccessBlock(YES);
                                                   } else {
                                                       if (_instagramSuccessBlock) _instagramSuccessBlock(NO);
                                                   }
                                               } failure:^(NSError *error) {
                                                   DDLogError(@"Instagram accessToken request failed: %@", error);
                                                   if (_instagramFailureBlock) _instagramFailureBlock(error);
                                               }];
}

- (void)checkForValidInstagramAuthenticationWithSuccess:(MRSLSocialSuccessBlock)successOrNil
                                                failure:(MRSLSocialFailureBlock)failureOrNil {
    if (!self.socialAuthentication) {
        if (failureOrNil) failureOrNil(nil);
        return;
    }
    __weak __typeof(self) weakSelf = self;
    [self.socialAuthentication API_validateAuthentication:^(BOOL success) {
        if (weakSelf.instagramCredentials && success) {
            if (successOrNil) successOrNil(YES);
        } else {
            if (failureOrNil) failureOrNil(nil);
        }
    }];
}

- (void)restoreInstagramWithAuthentication:(MRSLSocialAuthentication *)authentication
                              shouldCreate:(BOOL)shouldCreate {
    self.socialAuthentication = authentication;
    if (!_instagramCredentials) {
        AFOAuthCredential *credential = [[AFOAuthCredential alloc] initWithOAuthToken:authentication.token
                                                                            tokenType:authentication.tokenType ?: @"bearer"
                                                                             response:@{@"user": @{@"id": authentication.uid,
                                                                                                   @"username": authentication.username}}];
        [_oauth2Client setAuthorizationHeaderWithCredential:credential];
        self.instagramCredentials = credential;
    }
    __weak __typeof(self) weakSelf = self;
    [self getInstagramUserInformation:^(NSDictionary *userInfo, NSError *error) {
        if (!error && userInfo) {
            if (shouldCreate && [MRSLUser currentUser]) {
                [_appDelegate.apiService createUserAuthentication:authentication
                                                          success:nil
                                                          failure:^(NSError *error) {
                                                              MRSLServiceErrorInfo *serviceErrorInfo = error.userInfo[JSONResponseSerializerWithServiceErrorInfoKey];
                                                              if ([[serviceErrorInfo.errorInfo lowercaseString] isEqualToString:@"uid: already exists"]) {
                                                                  [UIAlertView showOKAlertViewWithTitle:@"Instagram Account Taken"
                                                                                                message:@"This Instagram account has already been associated with another Morsel account."];
                                                                  [weakSelf reset];
                                                                  if (_instagramFailureBlock) _instagramFailureBlock(error);
                                                              }
                                                          }];
            }
        }
    }];
}

- (void)getInstagramUserInformation:(MRSLSocialUserInfoBlock)userInfoBlockOrNil {
    int userID = [_instagramCredentials.authorizationResponse[@"user"][@"id"] intValue];
    __weak __typeof(self)weakSelf = self;
    [_oauth2Client GET:[NSString stringWithFormat:@"v1/users/%i?access_token=%@", userID, _instagramCredentials.accessToken]
            parameters:nil
               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                   DDLogVerbose(@"Instagram User Information Response: %@", responseObject);
                   NSDictionary *data = responseObject[@"data"];
                   NSMutableArray *nameArray = [[data[@"full_name"] componentsSeparatedByString:@" "] mutableCopy];
                   NSString *firstName = [nameArray firstObject];
                   [nameArray removeObjectAtIndex:0];
                   NSString *lastName = ([nameArray count] > 0) ? [nameArray componentsJoinedByString:@" "] : @"";
                   NSDictionary *userInfo = @{@"first_name": NSNullIfNil(firstName),
                                              @"last_name": NSNullIfNil(lastName),
                                              @"uid": NSNullIfNil(data[@"id"]),
                                              @"username": NSNullIfNil(data[@"username"]),
                                              @"pictureURL": NSNullIfNil(data[@"profile_picture"]),
                                              @"provider": @"instagram"};
                   if (userInfoBlockOrNil) userInfoBlockOrNil(userInfo, nil);
               } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                   if (operation.response.statusCode == 401) {
                       [weakSelf displaySessionExpiredAlert];
                       [weakSelf clearSocialAuthentication];
                   }
                   if (userInfoBlockOrNil) userInfoBlockOrNil(nil, error);
               }];
}

- (void)getInstagramFollowingUIDs:(MRSLSocialUIDStringBlock)uidBlockOrNil {
    if (_friendUIDs) {
        if (uidBlockOrNil) uidBlockOrNil([self friendUIDString], nil);
        return;
    }
    int userID = [_instagramCredentials.authorizationResponse[@"user"][@"id"] intValue];
    __weak __typeof(self)weakSelf = self;
    [_oauth2Client GET:[NSString stringWithFormat:@"v1/users/%i/follows?access_token=%@", userID, _instagramCredentials.accessToken]
            parameters:nil
               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                   DDLogVerbose(@"Instagram Friends Response: %@", responseObject);
                   __block NSMutableArray *friendUIDs = [NSMutableArray array];
                   NSArray *friendArray = responseObject[@"data"];
                   [friendArray enumerateObjectsUsingBlock:^(NSDictionary *instagramFriend, NSUInteger idx, BOOL *stop) {
                       [friendUIDs addObject:instagramFriend[@"id"]];
                   }];
                   self.friendUIDs = friendUIDs;
                   if (uidBlockOrNil) uidBlockOrNil([self friendUIDString], nil);
               } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                   if (operation.response.statusCode == 401) {
                       [weakSelf displaySessionExpiredAlert];
                       [weakSelf clearSocialAuthentication];
                   }
                   if (uidBlockOrNil) uidBlockOrNil(nil, error);
               }];
}

- (NSString *)friendUIDString {
    return [NSString stringWithFormat:@"%@", [_friendUIDs componentsJoinedByString:@","]];
}

- (NSString *)instagramUsername {
    return _instagramCredentials.authorizationResponse[@"user"][@"username"];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Yes"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:MRSLInstagramReconnectingAccountNotification
                                                            object:nil];
        [self authenticateWithInstagramWithSuccess:^(BOOL success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:MRSLInstagramReconnectedAccountNotification
                                                                    object:nil];
            });
        } failure:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:MRSLInstagramReconnectAccountFailedNotification
                                                                    object:nil];
            });
        }];
    }
}

#pragma mark - Reset Methods

- (void)displaySessionExpiredAlert {
    [UIAlertView showAlertViewWithTitle:@"Instagram session error"
                                message:@"Your session is no longer valid. Would you like to reconnect your account?"
                               delegate:self
                      cancelButtonTitle:@"No"
                      otherButtonTitles:@"Yes", nil];
}

- (void)clearSocialAuthentication {
    if (!_clearingSocialAuthentication) {
        if (!self.socialAuthentication) {
            [self reset];
            return;
        }
        self.clearingSocialAuthentication = YES;
        __weak __typeof(self) weakSelf = self;
        [_socialAuthentication API_validateAuthentication:^(BOOL success) {
            if (success) {
                DDLogDebug(@"Instagram clearing social authentication from backend");

                [_appDelegate.apiService deleteUserAuthentication:_socialAuthentication
                                                          success:^(id responseObject) {
                                                              weakSelf.clearingSocialAuthentication = NO;
                                                          } failure:^(NSError *error) {
                                                              weakSelf.clearingSocialAuthentication = NO;
                                                          }];
            }

            [weakSelf reset];
        }];
    }
}

- (void)reset {
    NXOAuth2Account *account = [[NXOAuth2AccountStore sharedStore] accountWithIdentifier:MRSLInstagramAccountTypeKey];
    [[NXOAuth2AccountStore sharedStore] removeAccount:account];
    self.instagramCredentials = nil;
    self.socialAuthentication = nil;
}

@end
