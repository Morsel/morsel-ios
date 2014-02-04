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

#define TWITTER_CONSUMER_KEY @"<INSERT CONSUMER KEY HERE>"
#define TWITTER_CONSUMER_SECRET @"<INSERT CONSUMER SECRET HERE>"

@implementation SocialService

#pragma mark - Instance Methods

- (void)performReverseAuthForAccount:(ACAccount *)account withBlock:(MorselDataURLResponseErrorBlock)block {
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
