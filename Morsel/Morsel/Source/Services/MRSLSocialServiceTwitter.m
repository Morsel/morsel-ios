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

#import "MRSLAPIService+Authorization.h"
#import "MRSLAPIService+Profile.h"

#import "MRSLUser.h"

#if (defined(MORSEL_BETA) || defined(RELEASE))
#define TWITTER_CONSUMER_KEY @"ETEvZdAoQ4pzi1boCxdZoA"
#define TWITTER_CONSUMER_SECRET @"0CBD7gMuymBSBCqpy8G7uuLwyD7peyeUetAQZhUqu0"
#else
#define TWITTER_CONSUMER_KEY @"OWJtM9wGQSSdMctOI0gHkQ"
#define TWITTER_CONSUMER_SECRET @"21EsTV2n8QjBUGZPfYx5JPKnxjicxboV0IHflBZB6w"
#endif

/*
 Adding a strong reference due to potential bug of accountType being prematurely nil. This is added on top of the solution below for extra safety.

 Further information on this issue can be found on SO:
 http://stackoverflow.com/questions/13349187/strange-behaviour-when-trying-to-use-twitter-acaccount
 */

@interface MRSLSocialServiceTwitter ()
<UIActionSheetDelegate>

@property (strong, nonatomic) MRSLSocialSuccessBlock twitterSuccessBlock;
@property (strong, nonatomic) MRSLSocialFailureBlock twitterFailureBlock;

@property (strong, nonatomic) ACAccountStore *accountStore;
@property (strong, nonatomic) NSArray *twitterAccounts;

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
    }
    return self;
}

- (void)authenticateWithTwitterWithSuccess:(MRSLSocialSuccessBlock)successOrNil
                                   failure:(MRSLSocialFailureBlock)failureOrNil {
    self.twitterClient = [[AFOAuth1Client alloc] initWithBaseURL:[NSURL URLWithString:@"https://api.twitter.com/1.1/"]
                                                             key:TWITTER_CONSUMER_KEY
                                                          secret:TWITTER_CONSUMER_SECRET];
    // Your application will be sent to the background until the user authenticates, and then the app will be brought back using the callback URL
    [_twitterClient authorizeUsingOAuthWithRequestTokenPath:@"/oauth/request_token"
                                      userAuthorizationPath:@"/oauth/authorize"
                                                callbackURL:[NSURL URLWithString:@"tw-morsel://success"]
                                            accessTokenPath:@"/oauth/access_token"
                                               accessMethod:@"POST"
                                                      scope:nil
                                                    success:^(AFOAuth1Token *accessToken, id responseObject) {
                                                        if (accessToken) {
                                                            if (successOrNil) successOrNil(YES);
                                                        } else {
                                                            if (successOrNil) successOrNil(NO);
                                                        }
                                                    } failure:^(NSError *error) {
                                                        if (failureOrNil) failureOrNil(error);
                                                    }];
}

- (void)getTwitterUserInformation:(MRSLSocialUserInfoBlock)userInfoBlockOrNil {

    NSMutableURLRequest *request = [_twitterClient requestWithMethod:@"GET"
                                                                path:[NSString stringWithFormat:@"users/show.json?screen_name=%@", _twitterClient.accessToken.userInfo[@"screen_name"]]
                                                          parameters:nil];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperationManager manager] HTTPRequestOperationWithRequest:request
                                                                                                         success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                                                             NSMutableArray *nameArray = [[responseObject[@"name"] componentsSeparatedByString:@" "] mutableCopy];
                                                                                                             NSString *firstName = [nameArray firstObject];
                                                                                                             [nameArray removeObjectAtIndex:0];
                                                                                                             NSString *lastName = ([nameArray count] > 0) ? [nameArray componentsJoinedByString:@" "] : @"";
                                                                                                             NSDictionary *userInfo = @{@"first_name": NSNullIfNil(firstName),
                                                                                                                                        @"last_name": NSNullIfNil(lastName),
                                                                                                                                        @"uid": NSNullIfNil(responseObject[@"id"]),
                                                                                                                                        @"pictureURL": NSNullIfNil(responseObject[@"profile_image_url"]),
                                                                                                                                        @"provider": @"twitter"};
                                                                                                             if (userInfoBlockOrNil) userInfoBlockOrNil(userInfo, nil);
                                                                                                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                                                             if (userInfoBlockOrNil) userInfoBlockOrNil(nil, error);
                                                                                                         }];
    [manager.operationQueue addOperation:operation];
}





- (void)activateTwitterWithSuccess:(MRSLSocialSuccessBlock)successOrNil
                           failure:(MRSLSocialFailureBlock)failureOrNil {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        ACAccountStore *accountStore = [[ACAccountStore alloc] init];
        //  Get a list of their Twitter accounts
        NSArray *twitterAccounts = [accountStore accountsWithAccountType:[accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter]];

        if (successOrNil) self.twitterSuccessBlock = successOrNil;
        if (failureOrNil) self.twitterFailureBlock = failureOrNil;

        if ([twitterAccounts count] == 0) {
            //  Request to grab the accounts
            __weak typeof(self) weakSelf = self;
            [self requestReadAndWriteForTwitterAccountsWithBlock:^(BOOL granted, NSError *error) {
                if (granted) {
                    __strong typeof(weakSelf) strongSelf = weakSelf;
                    [strongSelf showActionSheetWithAccountsForTwitter];
                } else {
                    if (failureOrNil) failureOrNil(nil);
                    [UIAlertView showAlertViewForErrorString:[NSString stringWithFormat:(error.code == ACErrorAccountNotFound) ? @"Please add a Twitter Account to this device" : @"Unable to authorize with Twitter. Please check your settings."]
                                                    delegate:nil];
                }
            }];
        } else {
            [self showActionSheetWithAccountsForTwitter];
        }
    } else {
        if (failureOrNil) failureOrNil(nil);
        [UIAlertView showAlertViewForErrorString:@"Please add a Twitter Account to this device"
                                        delegate:nil];
    }
}

- (void)showActionSheetWithAccountsForTwitter {
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    NSArray *accounts = [accountStore accountsWithAccountType:[accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter]];
    NSMutableArray *buttonTitles = [NSMutableArray array];
    NSUInteger actionSheetTag = 0;

    for (ACAccount *account in accounts) {
        [buttonTitles addObject:account.username];
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
    if (buttonIndex == [self.twitterAccounts count]) {
        if (self.twitterFailureBlock) self.twitterFailureBlock(nil);
        return;
    }
    ACAccount *selectedAccount = self.twitterAccounts[buttonIndex];
    [self performReverseAuthForTwitterAccount:selectedAccount
                                    withBlock:^(NSData *data, NSURLResponse *response, NSError *error) {
                                        NSDictionary *params = [NSURL ab_parseURLQueryString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
                                        [_appDelegate.apiService createTwitterAuthorizationWithToken:params[@"oauth_token"]
                                                                                              secret:params[@"oauth_token_secret"]
                                                                                             forUser:[MRSLUser currentUser]
                                                                                             success:^(id responseObject) {
                                                                                                 [_appDelegate.apiService getUserProfile:[MRSLUser currentUser]
                                                                                                                                 success:nil
                                                                                                                                 failure:nil];
                                                                                                 [[MRSLEventManager sharedManager] track:@"User Authorized with Twitter"
                                                                                                                              properties:@{@"view": @"Social"}];
                                                                                                 if (self.twitterSuccessBlock) self.twitterSuccessBlock(YES);
                                                                                             } failure:^(NSError *error) {
                                                                                                 [[MRSLEventManager sharedManager] track:@"User Unable to Authorize with Twitter"
                                                                                                                              properties:@{@"view": @"Social"}];
                                                                                                 if (self.twitterFailureBlock) self.twitterFailureBlock(error);
                                                                                             }];
                                    }];
}

@end
