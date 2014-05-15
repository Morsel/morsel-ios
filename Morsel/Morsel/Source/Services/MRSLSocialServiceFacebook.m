//
//  MRSLSocialServiceFacebook.m
//  Morsel
//
//  Created by Javier Otero on 5/5/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLSocialServiceFacebook.h"

#import <Social/Social.h>

#import "MRSLAPIService+Authorization.h"
#import "MRSLAPIService+Profile.h"

#import "MRSLUser.h"

#if (defined(MORSEL_BETA) || defined(RELEASE))
#define FACEBOOK_APP_ID @"1402286360015732"
#else
#define FACEBOOK_APP_ID @"1406459019603393"
#endif

@interface MRSLSocialServiceFacebook ()

@property (strong, nonatomic) MRSLSocialSuccessBlock facebookSuccessBlock;
@property (strong, nonatomic) MRSLSocialFailureBlock facebookFailureBlock;
@property (copy, nonatomic) FBSessionStateHandler sessionStateHandlerBlock;

@property (strong, nonatomic) NSArray *facebookAccounts;

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

#pragma mark - Instance Methods

- (void)checkForValidFacebookSessionWithSessionStateHandler:(FBSessionStateHandler)handler {
    self.sessionStateHandlerBlock = handler;
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
        // If there's one, just open the session silently, without showing the user the login UI
        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile", @"email"]
                                           allowLoginUI:NO
                                      completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                          // Handler for session state changes
                                          // This method will be called EACH time the session state changes,
                                          // also for intermediate states and NOT just when the session open
                                          [self sessionStateChanged:session
                                                              state:state
                                                              error:error];
                                      }];
    }
}

- (void)openFacebookSessionWithSessionStateHandler:(FBSessionStateHandler)handler {
    self.sessionStateHandlerBlock = handler;
    // Open a session showing the user the login UI
    // You must ALWAYS ask for public_profile permissions when opening a session
    [FBSession openActiveSessionWithReadPermissions:@[@"public_profile", @"email"]
                                       allowLoginUI:YES
                                  completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                      // Call sessionStateChanged:state:error method to handle session state changes
                                      [self sessionStateChanged:session
                                                          state:state
                                                          error:error];
                                  }];
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
                              DDLogDebug(@"Facebook Picture Response: %@", result);
                              [userInfo setObject:result[@"data"][@"url"]
                                           forKey:@"pictureURL"];
                              [FBRequestConnection startWithGraphPath:@"/me"
                                                           parameters:nil
                                                           HTTPMethod:@"GET"
                                                    completionHandler:^(FBRequestConnection *connection, id result, NSError *userError) {
                                                        DDLogDebug(@"Facebook User Information Response: %@", result);
                                                        [userInfo setObject:result[@"first_name"]
                                                                     forKey:@"first_name"];
                                                        [userInfo setObject:result[@"last_name"]
                                                                     forKey:@"last_name"];
                                                        [userInfo setObject:result[@"email"]
                                                                     forKey:@"email"];
                                                        [userInfo setObject:result[@"id"]
                                                                     forKey:@"uid"];
                                                        [userInfo setObject:@"facebook"
                                                                     forKey:@"provider"];
                                                        facebookUserInfo(userInfo, userError);
                                                    }];
                          }];
}

#pragma mark - Private Methods

- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState)state
                      error:(NSError *)error {
    // If the session was opened successfully
    if (!error && state == FBSessionStateOpen){
        NSLog(@"Session opened");
        // Show the user the logged-in UI
        if (self.sessionStateHandlerBlock) self.sessionStateHandlerBlock(session, state, error);
        return;
    }
    if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed){
        // If the session is closed
        NSLog(@"Session closed");
        // Show the user the logged-out UI
        if (self.sessionStateHandlerBlock) self.sessionStateHandlerBlock(session, state, error);
    }

    // Handle errors
    if (error){
        NSLog(@"Error");
        NSString *alertText;
        NSString *alertTitle;
        // If the error requires people using an app to make an action outside of the app in order to recover
        if ([FBErrorUtility shouldNotifyUserForError:error] == YES){
            alertTitle = @"Something went wrong";
            alertText = [FBErrorUtility userMessageForError:error];
            [UIAlertView showAlertViewWithTitle:alertTitle
                                        message:alertText
                                       delegate:nil
                              cancelButtonTitle:nil
                              otherButtonTitles:nil];
        } else {

            // If the user cancelled login, do nothing
            if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
                NSLog(@"User cancelled login");

                // Handle session closures that happen outside of the app
            } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession){
                alertTitle = @"Session Error";
                alertText = @"Your current session is no longer valid. Please log in again.";
                [UIAlertView showAlertViewWithTitle:alertTitle
                                            message:alertText
                                           delegate:nil
                                  cancelButtonTitle:nil
                                  otherButtonTitles:nil];

                // Here we will handle all other errors with a generic error message.
                // We recommend you check our Handling Errors guide for more information
                // https://developers.facebook.com/docs/ios/errors/
            } else {
                //Get more error information from the error
                NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];

                // Show the user an error message
                alertTitle = @"Something went wrong";
                alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
                [UIAlertView showAlertViewWithTitle:alertTitle
                                            message:alertText
                                           delegate:nil
                                  cancelButtonTitle:nil
                                  otherButtonTitles:nil];
            }
        }
        // Clear this token
        [FBSession.activeSession closeAndClearTokenInformation];
        // Report Error (should log user out of FB)
        if (self.sessionStateHandlerBlock) self.sessionStateHandlerBlock(session, state, error);
    }
}

- (void)reset {
    if (FBSession.activeSession.state == FBSessionStateOpen
        || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {

        // Close the session and remove the access token from the cache
        // The session state handler (in the app delegate) will be called automatically
        [FBSession.activeSession closeAndClearTokenInformation];

        // If the session state is not any of the two "open" states when the button is clicked
    }
}

- (void)activateFacebookWithSuccess:(MRSLSocialSuccessBlock)successOrNil
                            failure:(MRSLSocialFailureBlock)failureOrNil {
    // Deprecated
}

@end
