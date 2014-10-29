//
//  MRSLSocialServiceTwitter.m
//  Morsel
//
//  Created by Javier Otero on 5/5/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLSocialServiceTwitter.h"

#import <Accounts/Accounts.h>
#import <OAuthCore/OAuthCore.h>
#import <OAuthCore/OAuth+Additions.h>
#import <Social/Social.h>

#import "MRSLAPIService+Authentication.h"
#import "MRSLAPIService+Profile.h"

#import "MRSLSocialAuthentication.h"

#import "MRSLUser.h"

/*
 Adding a strong reference due to potential bug of accountType being prematurely nil. This is added on top of the solution below for extra safety.

 Further information on this issue can be found on SO:
 http://stackoverflow.com/questions/13349187/strange-behaviour-when-trying-to-use-twitter-acaccount
 */

@interface MRSLSocialServiceTwitter ()
<UIActionSheetDelegate>

@property (nonatomic) BOOL clearingSocialAuthentication;

@property (strong, nonatomic) MRSLSocialSuccessBlock twitterSuccessBlock;
@property (strong, nonatomic) MRSLSocialFailureBlock twitterFailureBlock;

@property (strong, nonatomic) ACAccountStore *accountStore;
@property (strong, nonatomic) NSArray *twitterAccounts;
@property (strong, nonatomic) NSArray *friendUIDs;

@end

@implementation MRSLSocialServiceTwitter

+ (instancetype)sharedService {
    static MRSLSocialServiceTwitter *_sharedService = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _sharedService = [[MRSLSocialServiceTwitter alloc] init];
    });
    return _sharedService;
}

- (id)init {
    self = [super init];
    if (self) {
        self.accountStore = [[ACAccountStore alloc] init];
        self.oauth1Client = [[AFOAuth1Client alloc] initWithBaseURL:[NSURL URLWithString:@"https://api.twitter.com/1.1/"]
                                                                key:TWITTER_CONSUMER_KEY
                                                             secret:TWITTER_CONSUMER_SECRET];
    }
    return self;
}

#pragma mark - Authentication Methods

- (void)authenticateWithTwitterWithSuccess:(MRSLSocialSuccessBlock)successOrNil
                                   failure:(MRSLSocialFailureBlock)failureOrNil {
    if (successOrNil) self.twitterSuccessBlock = successOrNil;
    if (failureOrNil) self.twitterFailureBlock = failureOrNil;

    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        ACAccountStore *accountStore = [[ACAccountStore alloc] init];
        //  Get a list of their Twitter accounts
        NSArray *twitterAccounts = [accountStore accountsWithAccountType:[accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter]];
        if ([twitterAccounts count] == 0) {
            //  Request to grab the accounts
            __weak typeof(self) weakSelf = self;
            [self requestReadAndWriteForTwitterAccountsWithBlock:^(BOOL granted, NSError *error) {
                if (granted) {
                    __strong typeof(weakSelf) strongSelf = weakSelf;
                    [strongSelf showActionSheetWithAccountsForTwitter];
                } else {
                    [self authorizeUsingOAuth];
                }
            }];
        } else {
            [self showActionSheetWithAccountsForTwitter];
        }
    } else {
        [self authorizeUsingOAuth];
    }
}

- (void)checkForValidTwitterAuthenticationWithSuccess:(MRSLSocialSuccessBlock)successOrNil
                                              failure:(MRSLSocialFailureBlock)failureOrNil {
    if (!self.socialAuthentication) {
        if (failureOrNil) failureOrNil(nil);
        return;
    }
    AFOAuth1Token *twitterToken = [AFOAuth1Token retrieveCredentialWithIdentifier:MRSLTwitterCredentialsKey];
    __weak __typeof(self) weakSelf = self;
    [self.socialAuthentication API_validateAuthentication:^(BOOL success) {
        if (twitterToken && success) {
            weakSelf.oauth1Client.accessToken = twitterToken;
            [weakSelf getTwitterUserInformation:^(NSDictionary *userInfo, NSError *error) {
                if (!error) {
                    if (successOrNil) successOrNil(YES);
                } else {
                    if (failureOrNil) failureOrNil(nil);
                }
            }];
        } else {
            if (failureOrNil) failureOrNil(nil);
        }
    }];
}

- (void)restoreTwitterWithAuthentication:(MRSLSocialAuthentication *)authentication
                            shouldCreate:(BOOL)shouldCreate {
    self.socialAuthentication = authentication;
    if (!_oauth1Client.accessToken) {
        _oauth1Client.accessToken = [[AFOAuth1Token alloc] initWithKey:authentication.token
                                                                secret:authentication.secret
                                                               session:nil
                                                            expiration:nil
                                                             renewable:YES];
        _oauth1Client.accessToken.userInfo = @{@"screen_name": NSNullIfNil(authentication.username),
                                               @"user_id": NSNullIfNil(authentication.uid)};
    }
    __weak __typeof(self) weakSelf = self;
    [self getTwitterUserInformation:^(NSDictionary *userInfo, NSError *error) {
        if (!error && userInfo) {
            if (shouldCreate && [MRSLUser currentUser]) {
                [_appDelegate.apiService createUserAuthentication:authentication
                                                          success:nil
                                                          failure:^(NSError *error) {
                                                              MRSLServiceErrorInfo *serviceErrorInfo = error.userInfo[JSONResponseSerializerWithServiceErrorInfoKey];
                                                              if ([[serviceErrorInfo.errorInfo lowercaseString] isEqualToString:@"uid: already exists"]) {
                                                                  [UIAlertView showOKAlertViewWithTitle:@"Twitter Account Taken"
                                                                                                message:@"This Twitter account has already been associated with another Morsel account."];
                                                                  [weakSelf reset];
                                                                  if (_twitterFailureBlock) _twitterFailureBlock(error);
                                                              }
                                                          }];
            }
            [AFOAuth1Token storeCredential:weakSelf.oauth1Client.accessToken
                            withIdentifier:MRSLTwitterCredentialsKey];
        }
    }];
}

- (void)authorizeUsingOAuth {
    // Your application will be sent to the background until the user authenticates, and then the app will be brought back using the callback URL
    [_oauth1Client authorizeUsingOAuthWithRequestTokenPath:@"/oauth/request_token"
                                     userAuthorizationPath:@"/oauth/authorize"
                                               callbackURL:[NSURL URLWithString:TWITTER_CALLBACK]
                                           accessTokenPath:@"/oauth/access_token"
                                              accessMethod:@"POST"
                                                     scope:nil
                                                   success:^(AFOAuth1Token *accessToken, id responseObject) {
                                                       if (accessToken) {
                                                           MRSLSocialAuthentication *socialAuthentication = [[MRSLSocialAuthentication alloc] init];
                                                           socialAuthentication.provider = @"twitter";
                                                           socialAuthentication.token = accessToken.key;
                                                           socialAuthentication.secret = accessToken.secret;
                                                           socialAuthentication.username = accessToken.userInfo[@"screen_name"];
                                                           socialAuthentication.uid = accessToken.userInfo[@"user_id"];
                                                           [self restoreTwitterWithAuthentication:socialAuthentication
                                                                                     shouldCreate:YES];
                                                           if (_twitterSuccessBlock) _twitterSuccessBlock(YES);
                                                       } else {
                                                           if (_twitterSuccessBlock) _twitterSuccessBlock(NO);
                                                       }
                                                   } failure:^(NSError *error) {
                                                       if (_twitterFailureBlock) _twitterFailureBlock(error);
                                                   }];
}

#pragma mark - User Methods

- (void)getTwitterUserInformation:(MRSLSocialUserInfoBlock)userInfoBlockOrNil {
    __weak __typeof(self)weakSelf = self;

    NSMutableURLRequest *request = [_oauth1Client requestWithMethod:@"GET"
                                                               path:[NSString stringWithFormat:@"users/show.json?screen_name=%@", [self twitterUsername]]
                                                         parameters:nil];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperationManager manager] HTTPRequestOperationWithRequest:request
                                                                                                         success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                                                             DDLogVerbose(@"Twitter User Information Response: %@", responseObject);
                                                                                                             NSMutableArray *nameArray = [[responseObject[@"name"] componentsSeparatedByString:@" "] mutableCopy];
                                                                                                             NSString *firstName = [nameArray firstObject];
                                                                                                             [nameArray removeObjectAtIndex:0];
                                                                                                             NSString *lastName = ([nameArray count] > 0) ? [nameArray componentsJoinedByString:@" "] : @"";
                                                                                                             NSDictionary *userInfo = @{@"first_name": NSNullIfNil(firstName),
                                                                                                                                        @"last_name": NSNullIfNil(lastName),
                                                                                                                                        @"uid": NSNullIfNil(responseObject[@"id_str"]),
                                                                                                                                        @"pictureURL": NSNullIfNil(responseObject[@"profile_image_url"]),
                                                                                                                                        @"provider": @"twitter"};
                                                                                                             if (userInfoBlockOrNil) userInfoBlockOrNil(userInfo, nil);
                                                                                                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                                                             if (operation.response.statusCode == 401) {
                                                                                                                 [weakSelf displaySessionExpiredAlert];
                                                                                                                 [weakSelf clearSocialAuthentication];
                                                                                                             }
                                                                                                             if (userInfoBlockOrNil) userInfoBlockOrNil(nil, error);
                                                                                                         }];
    [manager.operationQueue addOperation:operation];
}

- (void)getTwitterFollowingUIDs:(MRSLSocialUIDStringBlock)uidBlockOrNil {
    if (_friendUIDs) {
        if (uidBlockOrNil) uidBlockOrNil([self friendUIDString], nil);
        return;
    }
    __weak __typeof(self)weakSelf = self;
    NSMutableURLRequest *request = [_oauth1Client requestWithMethod:@"GET"
                                                               path:[NSString stringWithFormat:@"friends/ids.json?screen_name=%@", [self twitterUsername]]
                                                         parameters:nil];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperationManager manager] HTTPRequestOperationWithRequest:request
                                                                                                         success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                                                             DDLogVerbose(@"Twitter Friends Response: %@", responseObject);
                                                                                                             __block NSMutableArray *friendUIDs = [NSMutableArray array];
                                                                                                             NSArray *friendArray = responseObject[@"ids"];
                                                                                                             [friendArray enumerateObjectsUsingBlock:^(NSNumber *friendID, NSUInteger idx, BOOL *stop) {
                                                                                                                 [friendUIDs addObject:[friendID stringValue]];
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
    [manager.operationQueue addOperation:operation];
}

- (NSString *)friendUIDString {
    return [NSString stringWithFormat:@"%@", [_friendUIDs componentsJoinedByString:@","]];
}

- (NSString *)twitterUsername {
    return _oauth1Client.accessToken.userInfo[@"screen_name"];
}

#pragma mark - Status Methods

- (void)postStatus:(NSString *)status
           success:(MRSLSocialSuccessBlock)successOrNil
           failure:(MRSLSocialFailureBlock)failureOrNil {
    NSMutableURLRequest *request = [_oauth1Client requestWithMethod:@"POST"
                                                               path:@"statuses/update.json"
                                                         parameters:@{@"status": status}];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];

    __weak __typeof(self)weakSelf = self;
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperationManager manager] HTTPRequestOperationWithRequest:request
                                                                                                         success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                                                             DDLogVerbose(@"Twitter Status Update Response: %@", responseObject);

                                                                                                             if (successOrNil) successOrNil(YES);
                                                                                                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                                                             if (operation.response.statusCode == 401) {
                                                                                                                 [weakSelf displaySessionExpiredAlert];
                                                                                                                 [weakSelf clearSocialAuthentication];
                                                                                                             }
                                                                                                             if (failureOrNil) failureOrNil(error);
                                                                                                         }];
    [manager.operationQueue addOperation:operation];
}

#pragma mark - Reset Methods

- (void)displaySessionExpiredAlert {
    [UIAlertView showAlertViewWithTitle:@"Twitter session error"
                                message:@"Your session is no longer valid. Please connect to Twitter again in Settings."
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil];
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
                DDLogDebug(@"Twitter clearing social authentication from backend");

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
    [AFOAuth1Token deleteCredentialWithIdentifier:MRSLTwitterCredentialsKey];
    self.oauth1Client.accessToken = nil;
    self.socialAuthentication = nil;
}

#pragma mark - iOS ACAccount Methods


- (void)showActionSheetWithAccountsForTwitter {
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    NSArray *accounts = [accountStore accountsWithAccountType:[accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter]];
    NSMutableArray *buttonTitles = [NSMutableArray array];
    NSUInteger actionSheetTag = 0;

    for (ACAccount *account in accounts) {
        if (account.username) [buttonTitles addObject:account.username];
    }
    self.twitterAccounts = [accountStore accountsWithAccountType:[accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter]];
    actionSheetTag = CreateMorselActionSheetTwitterAccounts;

    dispatch_async(dispatch_get_main_queue(), ^{
        //  show actionsheet with accounts and 'Cancel'
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose an Account"
                                                                 delegate:self
                                                        cancelButtonTitle:nil
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:nil];
        for (NSString *buttonTitle in buttonTitles) {
            [actionSheet addButtonWithTitle:buttonTitle];
        }

        [actionSheet setCancelButtonIndex:[actionSheet addButtonWithTitle:@"Cancel"]];
        [actionSheet setTag:actionSheetTag];
        [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
    });
}

- (void)performReverseAuthForTwitterAccount:(ACAccount *)account withBlock:(MRSLDataURLResponseErrorBlock)block {
    NSParameterAssert(account);

    [self requestReverseAuthenticationSignatureWithBlock:^(NSData *reverseAuthenticationData, NSURLResponse *reverseAuthenticationResponse, NSError *reverseAuthenticationError) {
        if (reverseAuthenticationData) {
            [self requestAccessTokenForAccount:account
                                     signature:[[NSString alloc] initWithData:reverseAuthenticationData
                                                                     encoding:NSUTF8StringEncoding]
                                     withBlock:^(NSData *accessTokenData, NSURLResponse *accessTokenResponse, NSError *accessTokenError) {
                                         block(accessTokenData, accessTokenResponse, accessTokenError);
                                     }];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(nil, nil, reverseAuthenticationError);
            });
        }
    }];
}

- (void)requestReadAndWriteForTwitterAccountsWithBlock:(ACAccountStoreRequestAccessCompletionHandler)block {
    [self.accountStore requestAccessToAccountsWithType:[self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter]
                                               options:nil
                                            completion:block];
}

//  Step 1
- (void)requestReverseAuthenticationSignatureWithBlock:(MRSLDataURLResponseErrorBlock)block {
    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/oauth/request_token"];
    NSString *method = @"POST";
    NSData *bodyData = [@"x_auth_mode=reverse_auth" dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];

    [request setTimeoutInterval:10];
    [request setHTTPMethod:method];
    [request setValue:OAuthorizationHeader(url, method, bodyData, TWITTER_CONSUMER_KEY, TWITTER_CONSUMER_SECRET, nil, nil) forHTTPHeaderField:@"Authorization"];
    [request setHTTPBody:bodyData];

    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               block(data, response, connectionError);
                           }];
}

// Step 2
- (void)requestAccessTokenForAccount:(ACAccount *)account signature:(NSString *)signedReverseAuthenticationSignature withBlock:(MRSLDataURLResponseErrorBlock)block {
    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/oauth/access_token"];
    NSDictionary *params = @{ @"x_reverse_auth_target": TWITTER_CONSUMER_KEY,
                              @"x_reverse_auth_parameters": signedReverseAuthenticationSignature };

    SLRequest *accessTokenRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                       requestMethod:SLRequestMethodPOST
                                                                 URL:url
                                                          parameters:params];
    ACAccountType *accountTypeTwitter = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    account.accountType = accountTypeTwitter;
    [accessTokenRequest setAccount:account];

    [accessTokenRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            block(responseData, urlResponse, error);
        });
    }];
}

#pragma mark - UIActionSheetDelegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        if (_twitterFailureBlock) _twitterFailureBlock(nil);
        return;
    }
    __weak __typeof(self) weakSelf = self;
    ACAccount *selectedAccount = self.twitterAccounts[buttonIndex];
    [self performReverseAuthForTwitterAccount:selectedAccount
                                    withBlock:^(NSData *data, NSURLResponse *response, NSError *error) {
                                        if (!error) {
                                            NSDictionary *params = [NSURL ab_parseURLQueryString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
                                            MRSLSocialAuthentication *socialAuth = [[MRSLSocialAuthentication alloc] init];
                                            socialAuth.provider = @"twitter";
                                            socialAuth.token = params[@"oauth_token"];
                                            socialAuth.secret = params[@"oauth_token_secret"];
                                            socialAuth.username = params[@"screen_name"];
                                            socialAuth.uid = params[@"user_id"];
                                            [weakSelf restoreTwitterWithAuthentication:socialAuth
                                                                          shouldCreate:YES];
                                            if (_twitterSuccessBlock) _twitterSuccessBlock(YES);
                                        } else {
                                            if (_twitterFailureBlock) _twitterFailureBlock(error);
                                        }
                                    }];
}

@end
