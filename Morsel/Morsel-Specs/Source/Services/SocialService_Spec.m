//
//  SocialService_Spec.m
//  Morsel
//
//  Created by Marty Trzpit on 1/30/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <Accounts/Accounts.h>
#import <OHHTTPStubs/OHHTTPStubs.h>

#import "MRSLSocialService.h"
#import <Social/SLRequest.h>

@interface MRSLSocialService (PRIVATE)

- (void)requestReverseAuthenticationSignatureWithBlock:(MorselDataURLResponseErrorBlock)block;
- (void)requestAccessTokenForAccount:(ACAccount *)account signature:(NSString *)signedReverseAuthenticationSignature withBlock:(MorselDataURLResponseErrorBlock)block;

@end

SPEC_BEGIN(SocialServiceSpec)

describe(@"SocialService", ^{
    context(@"Twitter", ^{
        describe(@"- performReverseAuthForAccount:withBlock", ^{
            context(@"nil Twitter account", ^{
                it(@"throws an exception", ^{
                    [[[KWBlock blockWithBlock:^{
                        MRSLSocialService *socialService = [[MRSLSocialService alloc] init];
                        [socialService performReverseAuthForTwitterAccount:nil
                                                          withBlock:^(NSData *data, NSURLResponse *response, NSError *error) {}];
                    }] should] raise];
                });
            });
        });

        describe(@"- requestReverseAuthenticationSignatureWithBlock:", ^{
            it(@"get the signature for the application", ^{
                __weak NSData *dummyResponseData = [@"OAuth oauth_token=\"t0k3n\", \
                                                    oauth_signature_method=\"HMAC-SHA1\", \
                                                    oauth_consumer_key=\"s0m3_k3y\", \
                                                    oauth_signature=\"s0m3_s1gn4tur3\", \
                                                    oauth_nonce=\"n0nc3\", \
                                                    oauth_timestamp=\"1391203854\", \
                                                    oauth_version=\"1.0\"" dataUsingEncoding:NSUTF8StringEncoding];
                [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                    return [request.URL.absoluteString isEqualToString:@"https://api.twitter.com/oauth/request_token"];
                } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                    return [OHHTTPStubsResponse responseWithData:dummyResponseData
                                                      statusCode:200
                                                         headers:@{ @"Content-Type": @"applications/json" }];
                }];

                MRSLSocialService *socialService = [[MRSLSocialService alloc] init];

                __block BOOL success = NO;

                [socialService requestReverseAuthenticationSignatureWithBlock:^(NSData *data, NSURLResponse *response, NSError *error) {
                    success = [data isEqualToData:dummyResponseData] && (error == nil);
                }];

                [[expectFutureValue(theValue(success)) shouldEventually] beYes];
            });
        });

        describe(@"- requestAccessTokenForAccount:signature:withBlock", ^{
            it(@"gets the Access Token and Secret for the provided Account and reverse authentication signature", ^{
                __weak NSData *dummyResponseData = [@"oauth_token=0auth-t0k3n \
                                                    &oauth_token_secret=0autht0k3ns3cr3t \
                                                    &user_id=123456 \
                                                    &screen_name=eatmorsel" dataUsingEncoding:NSUTF8StringEncoding];

                ACAccountType *twitterAccountType = [[ACAccountType alloc] init];
                [twitterAccountType stub:@selector(identifier) andReturn:@"com.apple.twitter"];

                ACAccount *dummyAccount = [[ACAccount alloc] initWithAccountType:twitterAccountType];
                NSString *dummySignature = @"OAuth oauth_some_stuff=\"whatever\"";

                MRSLSocialService *socialService = [[MRSLSocialService alloc] init];

                __block BOOL success = NO;

                SLRequest *dummyRequest = [SLRequest nullMock];
                [SLRequest stub:@selector(requestForServiceType:requestMethod:URL:parameters:) andReturn:dummyRequest];

                [dummyRequest stub:@selector(performRequestWithHandler:) withBlock:^id(NSArray *params) {
                    MorselDataURLResponseErrorBlock requestHandler = params[0];

                    requestHandler(dummyResponseData, nil, nil);
                    return nil;
                }];


                [socialService requestAccessTokenForAccount:dummyAccount
                                                  signature:dummySignature
                                                  withBlock:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                      success = [data isEqualToData:dummyResponseData] && (error == nil);
                                                  }];

                [[expectFutureValue(theValue(success)) shouldEventually] beYes];
            });
        });
    });
});

SPEC_END
