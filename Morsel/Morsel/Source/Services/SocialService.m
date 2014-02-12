//
//  SocialService.m
//  Morsel
//
//  Created by Marty Trzpit on 1/30/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "SocialService.h"

#import <OAuthCore/OAuthCore.h>
#import <Social/Social.h>

#if (defined(MORSEL_BETA) || defined(RELEASE))

#define TWITTER_CONSUMER_KEY @"ETEvZdAoQ4pzi1boCxdZoA"
#define TWITTER_CONSUMER_SECRET @"0CBD7gMuymBSBCqpy8G7uuLwyD7peyeUetAQZhUqu0"
#define FACEBOOK_APP_ID @"1402286360015732"

#else

#define TWITTER_CONSUMER_KEY @"fzFpTGULTLwwicIpqLH21g"
#define TWITTER_CONSUMER_SECRET @"7jN2Hz1F2WDbuWOrPYmI4INPLiQv9NF8l1ycnJ76EE"
#define FACEBOOK_APP_ID @"1406459019603393"

#endif

#ifdef RELEASE
#define FACEBOOK_PUBLISH_AUDIENCE ACFacebookAudienceEveryone
#else
#define FACEBOOK_PUBLISH_AUDIENCE ACFacebookAudienceOnlyMe
#endif

@interface SocialService ()

/*
 Adding a strong reference due to potential bug of accountType being prematurely nil. This is added on top of the solution below for extra safety.

 Further information on this issue can be found on SO:
 http://stackoverflow.com/questions/13349187/strange-behaviour-when-trying-to-use-twitter-acaccount
 */

@property (nonatomic, strong) ACAccountStore *accountStore;

@end

@implementation SocialService

- (id)init {
    self = [super init];
    if (self) {
        self.accountStore = [[ACAccountStore alloc] init];
    }
    return self;
}

#pragma mark - Instance Methods

- (void)performReverseAuthForTwitterAccount:(ACAccount *)account withBlock:(MorselDataURLResponseErrorBlock)block {
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
    [_accountStore requestAccessToAccountsWithType:[_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter]
                                          options:nil
                                       completion:block];
}

- (void)requestReadAndWriteForFacebookAccountsWithBlock:(ACAccountStoreRequestAccessCompletionHandler)block {
    [_accountStore requestAccessToAccountsWithType:[_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook]
                                          options:@{ ACFacebookAppIdKey : FACEBOOK_APP_ID,
                                                     ACFacebookPermissionsKey: @[ @"basic_info", @"email" ] }
                                       completion:^(BOOL readGranted, NSError *readError) {
                                           if (readGranted) {
                                               [_accountStore requestAccessToAccountsWithType:[_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook]
                                                                                     options:@{ ACFacebookAppIdKey : FACEBOOK_APP_ID,
                                                                                                ACFacebookAudienceKey: FACEBOOK_PUBLISH_AUDIENCE,
                                                                                                ACFacebookPermissionsKey: @[ @"publish_stream" ] }
                                                                                  completion:block];
                                           } else {
                                               if (block) block(NO, readError);
                                           }
                                       }];
}


#pragma mark - Private Methods

//  Step 1
- (void)requestReverseAuthenticationSignatureWithBlock:(MorselDataURLResponseErrorBlock)block {
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
- (void)requestAccessTokenForAccount:(ACAccount *)account signature:(NSString *)signedReverseAuthenticationSignature withBlock:(MorselDataURLResponseErrorBlock)block {
    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/oauth/access_token"];
    NSDictionary *params = @{ @"x_reverse_auth_target": TWITTER_CONSUMER_KEY,
                              @"x_reverse_auth_parameters": signedReverseAuthenticationSignature };

    SLRequest *accessTokenRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                       requestMethod:SLRequestMethodPOST
                                                                 URL:url
                                                          parameters:params];

    [accessTokenRequest setAccount:account];

    [accessTokenRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            block(responseData, urlResponse, error);
        });
    }];
}

@end
