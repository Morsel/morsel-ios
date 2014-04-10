//
//  SocialService.m
//  Morsel
//
//  Created by Marty Trzpit on 1/30/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLSocialService.h"

#import <Accounts/Accounts.h>
#import <OAuthCore/OAuthCore.h>
#import <OAuthCore/OAuth+Additions.h>
#import <Social/Social.h>

#import "MRSLItem.h"
#import "MRSLMorsel.h"
#import "MRSLUser.h"

NS_ENUM(NSUInteger, CreateMorselActionSheet) {
    CreateMorselActionSheetSettings = 1,
    CreateMorselActionSheetFacebookAccounts,
    CreateMorselActionSheetTwitterAccounts
};

#if (defined(MORSEL_BETA) || defined(RELEASE))

#define TWITTER_CONSUMER_KEY @"ETEvZdAoQ4pzi1boCxdZoA"
#define TWITTER_CONSUMER_SECRET @"0CBD7gMuymBSBCqpy8G7uuLwyD7peyeUetAQZhUqu0"
#define FACEBOOK_APP_ID @"1402286360015732"

#else

#define TWITTER_CONSUMER_KEY @"OWJtM9wGQSSdMctOI0gHkQ"
#define TWITTER_CONSUMER_SECRET @"21EsTV2n8QjBUGZPfYx5JPKnxjicxboV0IHflBZB6w"
#define FACEBOOK_APP_ID @"1406459019603393"

#endif

#ifdef RELEASE
#define FACEBOOK_PUBLISH_AUDIENCE ACFacebookAudienceEveryone
#else
#define FACEBOOK_PUBLISH_AUDIENCE ACFacebookAudienceOnlyMe
#endif

@interface MRSLSocialService ()
<UIActionSheetDelegate>

/*
 Adding a strong reference due to potential bug of accountType being prematurely nil. This is added on top of the solution below for extra safety.

 Further information on this issue can be found on SO:
 http://stackoverflow.com/questions/13349187/strange-behaviour-when-trying-to-use-twitter-acaccount
 */


@property (strong, nonatomic) MRSLSocialSuccessBlock facebookSuccessBlock;
@property (strong, nonatomic) MRSLSocialFailureBlock facebookFailureBlock;
@property (strong, nonatomic) MRSLSocialSuccessBlock twitterSuccessBlock;
@property (strong, nonatomic) MRSLSocialFailureBlock twitterFailureBlock;

@property (strong, nonatomic) ACAccountStore *accountStore;
@property (strong, nonatomic) NSArray *twitterAccounts;
@property (strong, nonatomic) NSArray *facebookAccounts;

@end

@implementation MRSLSocialService

#pragma mark - Class Methods

+ (instancetype)sharedService {
    static MRSLSocialService *_sharedService = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _sharedService = [[MRSLSocialService alloc] init];
    });
    return _sharedService;
}

#pragma mark - Instance Methods

- (id)init {
    self = [super init];
    if (self) {
        self.accountStore = [[ACAccountStore alloc] init];
    }
    return self;
}

- (void)activateFacebookWithSuccess:(MRSLSocialSuccessBlock)successOrNil
                            failure:(MRSLSocialFailureBlock)failureOrNil {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        ACAccountStore *accountStore = [[ACAccountStore alloc] init];
        NSArray *facebookAccounts = [accountStore accountsWithAccountType:[accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook]];

        if (successOrNil) self.facebookSuccessBlock = successOrNil;
        if (failureOrNil) self.facebookFailureBlock = failureOrNil;

        if ([facebookAccounts count] == 0) {
            //  Request to grab the accounts
            __weak typeof(self) weakSelf = self;
            [self requestReadAndWriteForFacebookAccountsWithBlock:^(BOOL granted, NSError *error) {
                if (granted) {
                    __strong typeof(weakSelf) strongSelf = weakSelf;
                    [strongSelf showActionSheetWithAccountsForAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
                } else {
                    if (failureOrNil) failureOrNil(nil);
                    [UIAlertView showAlertViewForErrorString:[NSString stringWithFormat:@"Unable to authorize with Facebook. Please check your settings."]
                                                    delegate:nil];
                }
            }];
        } else {
            [self showActionSheetWithAccountsForAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
        }
    } else {
        if (failureOrNil) failureOrNil(nil);
        [UIAlertView showAlertViewForErrorString:@"Please add a Facebook Account to this device"
                                        delegate:nil];
    }
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
                    [strongSelf showActionSheetWithAccountsForAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
                } else {
                    if (failureOrNil) failureOrNil(nil);
                    [UIAlertView showAlertViewForErrorString:[NSString stringWithFormat:@"Unable to authorize with Twitter. Please check your settings."]
                                                    delegate:nil];
                }
            }];
        } else {
            [self showActionSheetWithAccountsForAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        }
    } else {
        if (failureOrNil) failureOrNil(nil);
        [UIAlertView showAlertViewForErrorString:@"Please add a Twitter Account to this device"
                                        delegate:nil];
    }
}

- (void)shareMorselToFacebook:(MRSLItem *)item
             inViewController:(UIViewController *)viewController
                      success:(MRSLSocialSuccessBlock)successOrNil
                       cancel:(MRSLSocialCancelBlock)cancelBlockOrNil {
    [self shareMorsel:item
            toService:SLServiceTypeFacebook
     inViewController:viewController
              success:successOrNil
               cancel:cancelBlockOrNil];
}

- (void)shareMorselToTwitter:(MRSLItem *)item
            inViewController:(UIViewController *)viewController
                     success:(MRSLSocialSuccessBlock)successOrNil
                      cancel:(MRSLSocialCancelBlock)cancelBlockOrNil {
    [self shareMorsel:item
            toService:SLServiceTypeTwitter
     inViewController:viewController
              success:successOrNil
               cancel:cancelBlockOrNil];
}

- (void)shareMorsel:(MRSLItem *)item
          toService:(NSString *)serviceType
   inViewController:(UIViewController *)viewController
            success:(MRSLSocialSuccessBlock)successOrNil
             cancel:(MRSLSocialCancelBlock)cancelBlockOrNil {
    if ([SLComposeViewController isAvailableForServiceType:serviceType]) {
        SLComposeViewController *slComposerSheet = [SLComposeViewController composeViewControllerForServiceType:serviceType];
        NSString *userNameOrTwitterHandle =  (item.morsel.creator.twitter_username && [serviceType isEqualToString:SLServiceTypeTwitter]) ? [NSString stringWithFormat:@"@%@", item.morsel.creator.twitter_username] : item.morsel.creator.fullName;
        [slComposerSheet setInitialText:[NSString stringWithFormat:@"‟%@” from %@ on %@", item.morsel.title, userNameOrTwitterHandle, ([serviceType isEqualToString:SLServiceTypeFacebook]) ? @"Morsel" : @"@eatmorsel"]];
        [slComposerSheet addURL:[NSURL URLWithString:item.morsel.url]];
        [viewController presentViewController:slComposerSheet
                                     animated:YES
                                   completion:nil];
        [slComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {;
            if (result == SLComposeViewControllerResultDone) {
                if (successOrNil) successOrNil(YES);
            } else {
                if (cancelBlockOrNil) cancelBlockOrNil();
            }
            if (![UIDevice currentDeviceSystemVersionIsAtLeastIOS7] && [serviceType isEqualToString:SLServiceTypeTwitter]) {
                // Corrects an issue where Twitter compose sheet is not correctly dismissing in iOS 6. Known Apple bug that was resolved in iOS 7.
                [viewController dismissViewControllerAnimated:YES
                                                   completion:nil];
            }
        }];
    } else {
        [UIAlertView showAlertViewForErrorString:[NSString stringWithFormat:@"Please add a %@ Account to this device", (serviceType == SLServiceTypeFacebook) ? @"Facebook" : @"Twitter"]
                                        delegate:nil];
    }
}

#pragma mark - Interaction Methods

- (void)showActionSheetWithAccountsForAccountTypeIdentifier:(NSString *)accountTypeIdentifier {
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    NSArray *accounts = [accountStore accountsWithAccountType:[accountStore accountTypeWithAccountTypeIdentifier:accountTypeIdentifier]];
    NSMutableArray *buttonTitles = [NSMutableArray array];
    NSUInteger actionSheetTag = 0;

    if ([accountTypeIdentifier isEqualToString:ACAccountTypeIdentifierFacebook]) {
        for (ACAccount *account in accounts) {
            NSString *fullName = [[account valueForKey:@"properties"] objectForKey:@"ACPropertyFullName"];
            if (fullName.length > 0) {
                [buttonTitles addObject:[NSString stringWithFormat:@"%@ (%@)", fullName, account.username]];
            } else {
                [buttonTitles addObject:account.username];
            }
        }
        _facebookAccounts = [accountStore accountsWithAccountType:[accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook]];
        actionSheetTag = CreateMorselActionSheetFacebookAccounts;
    } else {
        for (ACAccount *account in accounts) {
            [buttonTitles addObject:account.username];
        }
        _twitterAccounts = [accountStore accountsWithAccountType:[accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter]];
        actionSheetTag = CreateMorselActionSheetTwitterAccounts;
    }

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

#pragma mark - Private Methods

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

    [accessTokenRequest setAccount:account];

    [accessTokenRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            block(responseData, urlResponse, error);
        });
    }];
}

#pragma mark - UIActionSheetDelegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == CreateMorselActionSheetFacebookAccounts) {
        if (buttonIndex == [_facebookAccounts count]) {
            if (_facebookFailureBlock) _facebookFailureBlock(nil);
            return;
        }
        MRSLSocialService *socialService = [[MRSLSocialService alloc] init];
        [socialService requestReadAndWriteForFacebookAccountsWithBlock:^(BOOL granted, NSError *error) {
            if (error) {
                [UIAlertView showAlertViewForError:error
                                          delegate:nil];
            } else {
                //  Get _facebookAccounts again after access has been granted, otherwise the account's credential will be nil
                _facebookAccounts = [_accountStore accountsWithAccountType:[_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook]];
                ACAccount *selectedAccount = _facebookAccounts[buttonIndex];
                [_appDelegate.itemApiService createFacebookAuthorizationWithToken:[[selectedAccount credential] oauthToken]
                                                                          forUser:[MRSLUser currentUser]
                                                                          success:^(id responseObject) {
                                                                              [_appDelegate.itemApiService getUserProfile:[MRSLUser currentUser]
                                                                                                                  success:nil
                                                                                                                  failure:nil];
                                                                              [[MRSLEventManager sharedManager] track:@"User Authorized with Facebook"
                                                                                                           properties:@{@"view": @"Social"}];
                                                                              if (_facebookSuccessBlock) _facebookSuccessBlock(YES);
                                                                          } failure:^(NSError *error) {
                                                                              [[MRSLEventManager sharedManager] track:@"User Unable to Authorize with Facebook"
                                                                                                           properties:@{@"view": @"Social"}];
                                                                              if (_facebookFailureBlock) _facebookFailureBlock(error);
                                                                          }];
            }
        }];
    } else if (actionSheet.tag == CreateMorselActionSheetTwitterAccounts) {
        if (buttonIndex == [_twitterAccounts count]) {
            if (_twitterFailureBlock) _twitterFailureBlock(nil);
            return;
        }
        ACAccount *selectedAccount = _twitterAccounts[buttonIndex];
        [self performReverseAuthForTwitterAccount:selectedAccount
                                        withBlock:^(NSData *data, NSURLResponse *response, NSError *error) {
                                            NSDictionary *params = [NSURL ab_parseURLQueryString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
                                            [_appDelegate.itemApiService createTwitterAuthorizationWithToken:params[@"oauth_token"]
                                                                                                      secret:params[@"oauth_token_secret"]
                                                                                                     forUser:[MRSLUser currentUser]
                                                                                                     success:^(id responseObject) {
                                                                                                         [_appDelegate.itemApiService getUserProfile:[MRSLUser currentUser]
                                                                                                                                             success:nil
                                                                                                                                             failure:nil];
                                                                                                         [[MRSLEventManager sharedManager] track:@"User Authorized with Twitter"
                                                                                                                                      properties:@{@"view": @"Social"}];
                                                                                                         if (_twitterSuccessBlock) _twitterSuccessBlock(YES);
                                                                                                     } failure:^(NSError *error) {
                                                                                                         [[MRSLEventManager sharedManager] track:@"User Unable to Authorize with Twitter"
                                                                                                                                      properties:@{@"view": @"Social"}];
                                                                                                         if (_twitterFailureBlock) _twitterFailureBlock(error);
                                                                                                     }];
                                        }];
    }
}

@end
