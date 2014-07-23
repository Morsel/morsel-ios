//
//  MRSLSocialServiceFacebook.m
//  Morsel
//
//  Created by Javier Otero on 5/5/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLSocialServiceFacebook.h"

#import <Social/Social.h>

#import "MRSLAPIService+Authentication.h"
#import "MRSLAPIService+Profile.h"

#import "MRSLSocialAuthentication.h"

#import "MRSLMorsel.h"
#import "MRSLUser.h"

@interface MRSLSocialServiceFacebook ()

@property (copy, nonatomic) FBSessionStateHandler sessionStateHandlerBlock;

@property (strong, nonatomic) NSArray *facebookAccounts;
@property (strong, nonatomic) NSArray *friendUIDs;

@end

@implementation MRSLSocialServiceFacebook

#pragma mark - Class Methods

+ (instancetype)sharedService {
    static MRSLSocialServiceFacebook *_sharedService = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _sharedService = [[MRSLSocialServiceFacebook alloc] init];
    });
    return _sharedService;
}

#pragma mark - Authentication and User Information Methods

- (void)checkForValidFacebookSessionWithSessionStateHandler:(FBSessionStateHandler)handler {
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
        self.sessionStateHandlerBlock = handler;
        __block BOOL didConfirmValid = NO;
        __weak __typeof(self) weakSelf = self;
        // If there's one, just open the session silently, without showing the user the login UI
        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile", @"email", @"user_friends"]
                                           allowLoginUI:NO
                                      completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                          // Handler for session state changes
                                          // This method will be called EACH time the session state changes,
                                          // also for intermediate states and NOT just when the session open
                                          [self sessionStateChanged:session
                                                              state:status
                                                              error:error];
                                          if (!didConfirmValid) {
                                              [weakSelf checkForPublishPermissions:nil];
                                              didConfirmValid = YES;
                                          }
                                      }];
    }
}

- (void)checkForPublishPermissions:(MRSLSocialSuccessBlock)canPublishOrNil {
    if ([[FBSession activeSession] isOpen]) {
        // Call permissions just to be extra sure, since it could possibly not be restored.
        [FBRequestConnection startWithGraphPath:@"/me/permissions"
                              completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                  if (!error){
                                      __block BOOL canPublish = NO;
                                      NSArray *permissionArray = result[@"data"];
                                      [permissionArray enumerateObjectsUsingBlock:^(NSDictionary *permissionDictionary, NSUInteger idx, BOOL *stop) {
                                          if ([permissionDictionary[@"permission"] isEqualToString:@"publish_actions"]) {
                                              canPublish = YES;
                                              *stop = YES;
                                          }
                                      }];
                                      if (canPublishOrNil) canPublishOrNil(canPublish);
                                  }
                              }];
    } else {
        if (canPublishOrNil) canPublishOrNil(NO);
    }
}

- (void)openFacebookSessionWithSessionStateHandler:(FBSessionStateHandler)handler {
    self.sessionStateHandlerBlock = handler;
    self.socialAuthentication = [[MRSLSocialAuthentication alloc] init];
    // Open a session showing the user the login UI
    // You must ALWAYS ask for public_profile permissions when opening a session
    [FBSession openActiveSessionWithReadPermissions:@[@"public_profile", @"email", @"user_friends"]
                                       allowLoginUI:YES
                                  completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                      // Handler for session state changes
                                      [self sessionStateChanged:session
                                                          state:status
                                                          error:error];
                                  }];
}

- (void)requestPublishPermissionsWithCompletion:(FBSessionRequestPermissionResultHandler)completionOrNil {
    [FBSession.activeSession requestNewPublishPermissions:[NSArray arrayWithObject:@"publish_actions"]
                                          defaultAudience:FBSessionDefaultAudienceFriends
                                        completionHandler:^(FBSession *session, NSError *error) {
                                            if (completionOrNil) completionOrNil(session, error);
                                        }];
}

- (void)restoreFacebookSessionWithAuthentication:(MRSLSocialAuthentication *)authentication {
    self.socialAuthentication = authentication;
    if (![[FBSession activeSession] isOpen]) {
        NSArray *permissions = @[@"public_profile", @"email", @"user_friends"];
        FBSession *restoredSession = [[FBSession alloc] initWithPermissions:permissions];
        FBAccessTokenData *accessTokenData = [FBAccessTokenData createTokenFromString:authentication.token
                                                                          permissions:permissions
                                                                       expirationDate:nil
                                                                            loginType:FBSessionLoginTypeNone
                                                                          refreshDate:nil];
        @try {
            __weak __typeof(self) weakSelf = self;
            __block BOOL didConfirmValid = NO;
            [restoredSession openFromAccessTokenData:accessTokenData
                                   completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                       // Handler for session state changes
                                       [weakSelf sessionStateChanged:session
                                                               state:status
                                                               error:error];
                                       if (!didConfirmValid) {
                                           [weakSelf checkForPublishPermissions:nil];
                                           didConfirmValid = YES;
                                       }
                                   }];
            [FBSession setActiveSession:restoredSession];
        } @catch (NSException *exception) {
            DDLogError(@"Attempting to restore Facebook session with authentication threw exception: %@", exception);
            // This is likely due to permissions not matching the local Facebook sessions.
            // In that case, removing from API to ensure when session is re-authorized, it does not collide with Facebook uid.
            [self clearSocialAuthentication];
        }
    }
}

- (void)getFacebookUserInformation:(MRSLSocialUserInfoBlock)facebookUserInfo {
    NSDictionary *parameters = @{@"redirect": @"false",
                                 @"width": @"640",
                                 @"height": @"640",
                                 @"type": @"normal"};
    __block NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];

    [FBRequestConnection startWithGraphPath:@"/me/picture"
                                 parameters:parameters
                                 HTTPMethod:@"GET"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              DDLogVerbose(@"Facebook Picture Response: %@", result);
                              [userInfo setObject:NSNullIfNil(result[@"data"][@"url"])
                                           forKey:@"pictureURL"];
                              [FBRequestConnection startWithGraphPath:@"/me"
                                                           parameters:nil
                                                           HTTPMethod:@"GET"
                                                    completionHandler:^(FBRequestConnection *connection, id result, NSError *userError) {
                                                        DDLogVerbose(@"Facebook User Information Response: %@", result);
                                                        [userInfo setObject:result[@"first_name"] ?: @""
                                                                     forKey:@"first_name"];
                                                        [userInfo setObject:result[@"last_name"] ?: @""
                                                                     forKey:@"last_name"];
                                                        [userInfo setObject:result[@"email"] ?: @""
                                                                     forKey:@"email"];
                                                        [userInfo setObject:NSNullIfNil(result[@"id"])
                                                                     forKey:@"uid"];
                                                        [userInfo setObject:@"facebook"
                                                                     forKey:@"provider"];
                                                        if (facebookUserInfo) facebookUserInfo(userInfo, userError);
                                                    }];
                          }];
}

- (void)getFacebookFriendUIDs:(MRSLSocialUIDStringBlock)uidBlockOrNil {
    if (_friendUIDs) {
        if (uidBlockOrNil) uidBlockOrNil([self friendUIDString], nil);
        return;
    }
    [FBRequestConnection startWithGraphPath:@"/me/friends"
                                 parameters:nil
                                 HTTPMethod:@"GET"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              if (!error && result) {
                                  DDLogVerbose(@"Facebook Friends Response: %@", result);
                                  __block NSMutableArray *friendUIDs = [NSMutableArray array];
                                  NSArray *friendArray = result[@"data"];
                                  [friendArray enumerateObjectsUsingBlock:^(NSDictionary *friendDictionary, NSUInteger idx, BOOL *stop) {
                                      [friendUIDs addObject:friendDictionary[@"id"]];
                                  }];
                                  self.friendUIDs = friendUIDs;
                                  if (uidBlockOrNil) uidBlockOrNil([self friendUIDString], nil);
                              } else {
                                  if (uidBlockOrNil) uidBlockOrNil(nil, error);
                              }
                          }];
}

- (NSString *)friendUIDString {
    return [NSString stringWithFormat:@"%@", [_friendUIDs componentsJoinedByString:@","]];
}

- (NSString *)facebookUsername {
    return _socialAuthentication.username;
}

#pragma mark - Share Methods

- (void)shareMorsel:(MRSLMorsel *)morsel
            success:(MRSLSocialSuccessBlock)successOrNil
             cancel:(MRSLSocialCancelBlock)cancelBlockOrNil {
    // Check if the Facebook app is installed and we can present the share dialog
    FBLinkShareParams *fbLinkParams = [[FBLinkShareParams alloc] init];
    fbLinkParams.link = [NSURL URLWithString:morsel.facebook_mrsl ?: morsel.url];
    fbLinkParams.name = [NSString stringWithFormat:@"“%@” from %@ on Morsel", morsel.title, [morsel.creator fullName]];
    fbLinkParams.picture = [NSURL URLWithString:morsel.morselPhotoURL];

    // If the Facebook app is installed and we can present the share dialog
    if ([FBDialogs canPresentShareDialogWithParams:fbLinkParams]) {
        // Present share dialog
        [FBDialogs presentMessageDialogWithLink:fbLinkParams.link
                                           name:fbLinkParams.name
                                        caption:fbLinkParams.caption
                                    description:fbLinkParams.description
                                        picture:fbLinkParams.picture
                                    clientState:nil
                                        handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                            if (error) {
                                                // An error occurred, we need to handle the error
                                                // See: https://developers.facebook.com/docs/ios/errors
                                                DDLogError(@"Error publishing story: %@", error.description);
                                                if (successOrNil) successOrNil(NO);
                                            } else {
                                                // Success
                                                DDLogDebug(@"result %@", results);
                                                if (successOrNil) successOrNil(YES);
                                            }
                                        }];
    } else {
        // Present the feed dialog
        NSDictionary *parameters = @{@"name": NSNullIfNil(fbLinkParams.name),
                                     @"link": NSNullIfNil(fbLinkParams.link.absoluteString),
                                     @"picture": NSNullIfNil(fbLinkParams.picture.absoluteString)};
        // Show the feed dialog
        [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                               parameters:parameters
                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                      if (error) {
                                                          // An error occurred, we need to handle the error
                                                          // See: https://developers.facebook.com/docs/ios/errors
                                                          DDLogError(@"Error publishing story: %@", error.description);
                                                          if (successOrNil) successOrNil(NO);
                                                      } else {
                                                          if (result == FBWebDialogResultDialogNotCompleted) {
                                                              // User cancelled.
                                                              DDLogDebug(@"User cancelled.");
                                                              if (cancelBlockOrNil) cancelBlockOrNil();
                                                          } else {
                                                              // Handle the publish feed callback
                                                              NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                                                              if (![urlParams valueForKey:@"post_id"]) {
                                                                  // User cancelled.
                                                                  DDLogDebug(@"User cancelled.");
                                                                  if (cancelBlockOrNil) cancelBlockOrNil();
                                                              } else {
                                                                  // User clicked the Share button
                                                                  DDLogDebug(@"Morsel shared to Facebook story with id %@", [urlParams valueForKey:@"post_id"]);
                                                                  if (successOrNil) successOrNil(YES);
                                                              }
                                                          }
                                                      }
                                                  }];
    }
}

// A function for parsing URL parameters returned by the Feed Dialog.
- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}

#pragma mark - Private Methods

- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState)state
                      error:(NSError *)error {
    // If the session was opened successfully
    if (!error && state == FBSessionStateOpen) {
        DDLogDebug(@"Facebook session opened");
        // Show the user the logged-in UI
        if (self.sessionStateHandlerBlock) self.sessionStateHandlerBlock(session, state, error);
        if (_socialAuthentication && ![_socialAuthentication isValid] && [MRSLUser currentUser]) {
            __weak __typeof(self) weakSelf = self;
            [self getFacebookUserInformation:^(NSDictionary *userInfo, NSError *error) {
                __block MRSLSocialAuthentication *facebookAuthentication = [[MRSLSocialAuthentication alloc] init];
                facebookAuthentication.provider = @"facebook";
                facebookAuthentication.uid = userInfo[@"uid"];
                facebookAuthentication.token = session.accessTokenData.accessToken;
                [_appDelegate.apiService createUserAuthentication:facebookAuthentication
                                                          success:^(id responseObject) {
                                                              facebookAuthentication.authenticationID = responseObject[@"data"][@"id"];
                                                              weakSelf.socialAuthentication = facebookAuthentication;
                                                          } failure:nil];
            }];
        }
        return;
    } else if (state == FBSessionStateOpenTokenExtended) {
        DDLogDebug(@"Facebook session permissions extended");
        if ([_socialAuthentication isValid]) {
            if (![_socialAuthentication.token isEqualToString:session.accessTokenData.accessToken]) {
                _socialAuthentication.token = session.accessTokenData.accessToken;
                [_appDelegate.apiService updateUserAuthentication:_socialAuthentication
                                                          success:nil
                                                          failure:nil];
            }
        }
    }
    if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed){
        // If the session is closed
        DDLogDebug(@"Facebook session closed");
        [self clearSocialAuthentication];
        if (self.sessionStateHandlerBlock) self.sessionStateHandlerBlock(session, state, error);
    }

    if (error) {
        DDLogError(@"Facebook session error: %@", [error localizedDescription]);
        NSString *alertTitle = @"Facebook Session Error";
        // If the error requires people using an app to make an action outside of the app in order to recover
        if ([FBErrorUtility shouldNotifyUserForError:error] == YES){
            [UIAlertView showAlertViewWithTitle:alertTitle
                                        message:[FBErrorUtility userMessageForError:error]
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        } else {
            // If the user cancelled login, do nothing
            if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
                DDLogDebug(@"User cancelled facebook login");
                // Handle session closures that happen outside of the app
            } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {
                [UIAlertView showAlertViewWithTitle:alertTitle
                                            message:@"Your session is no longer valid. Please connect to Facebook again in Settings."
                                           delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];

                // Here we will handle all other errors with a generic error message.
                // We recommend you check our Handling Errors guide for more information
                // https://developers.facebook.com/docs/ios/errors/
                [self clearSocialAuthentication];
            } else {
                //Get more error information from the error
                NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
                // Show the user an error message
                [UIAlertView showAlertViewWithTitle:alertTitle
                                            message:[NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]]
                                           delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            }
        }
        [FBSession.activeSession closeAndClearTokenInformation];
        if (self.sessionStateHandlerBlock) self.sessionStateHandlerBlock(session, state, error);
    }
}

- (void)clearSocialAuthentication {
    if ([_socialAuthentication isValid]) {
        DDLogDebug(@"Facebook clearing social authentication from backend");
        [_appDelegate.apiService deleteUserAuthentication:_socialAuthentication
                                                  success:nil
                                                  failure:nil];
    }
}

- (void)reset {
    if (FBSession.activeSession.state == FBSessionStateOpen
        || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
        // Close the session and remove the access token from the cache
        // The session state handler (in the app delegate) will be called automatically
        self.socialAuthentication = nil;
        [FBSession.activeSession closeAndClearTokenInformation];
    }
}

@end
