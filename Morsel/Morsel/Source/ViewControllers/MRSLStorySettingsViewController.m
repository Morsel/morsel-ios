//
//  MRSLStorySettingsViewController.m
//  Morsel
//
//  Created by Javier Otero on 3/7/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLStorySettingsViewController.h"

#import "MRSLSocialService.h"

#import "MRSLMorsel.h"
#import "MRSLPost.h"
#import "MRSLUser.h"

#import <Accounts/Accounts.h>
#import <OAuthCore/OAuth+Additions.h>
#import <Social/Social.h>

NS_ENUM(NSUInteger, CreateMorselActionSheet) {
    CreateMorselActionSheetSettings = 1,
    CreateMorselActionSheetFacebookAccounts,
    CreateMorselActionSheetTwitterAccounts
};

@interface MRSLStorySettingsViewController ()
<UIActionSheetDelegate,
UIDocumentInteractionControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *twitterButton;
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UIButton *instagramButton;

@property (strong, nonatomic) NSArray *twitterAccounts;
@property (strong, nonatomic) NSArray *facebookAccounts;
@property (strong, nonatomic) UIDocumentInteractionController *documentInteractionController;

@property (strong, nonatomic) MRSLMorsel *morsel;

@end

@implementation MRSLStorySettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
#warning Toggle social based on previous preferences
#warning Remove Morsel property and figure out how share relates to entire Post
}

#pragma mark - Private Methods

- (IBAction)deleteStory {
    if ([_post.morsels count] == 0) {
        [_post MR_deleteEntity];
        [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfAndWait];
    } else {
        [_post.morsels enumerateObjectsUsingBlock:^(MRSLMorsel *morsel, BOOL *stop) {
            [_appDelegate.morselApiService deleteMorsel:morsel
                                                success:nil
                                                failure:nil];
        }];
    }
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)toggleFacebook:(UIButton *)button {
    MRSLUser *currentUser = [MRSLUser currentUser];

    [[MRSLEventManager sharedManager] track:@"Tapped Toggle Facebook"
                                 properties:@{@"view": @"MRSLCreateMorselViewController",
                                              @"morsel_id": NSNullIfNil(_morsel.morselID)}];

    if ([currentUser facebook_uid]) {
        [[MRSLEventManager sharedManager] track:@"User Already Authorized with Facebook"
                                     properties:@{@"view": @"MRSLCreateMorselViewController",
                                                  @"morsel_id": NSNullIfNil(_morsel.morselID)}];
        //  api already has a token, so just toggle the button
        [button setSelected:!button.selected];
    } else {
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
            ACAccountStore *accountStore = [[ACAccountStore alloc] init];
            NSArray *facebookAccounts = [accountStore accountsWithAccountType:[accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook]];

            if ([facebookAccounts count] == 0) {
                //  Request to grab the accounts
                MRSLSocialService *socialService = [[MRSLSocialService alloc] init];
                __weak typeof(self) weakSelf = self;
                [socialService requestReadAndWriteForFacebookAccountsWithBlock:^(BOOL granted, NSError *error) {
                    __strong typeof(weakSelf) strongSelf = weakSelf;
                    [strongSelf showActionSheetWithAccountsForAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
                }];
            } else {
                [self showActionSheetWithAccountsForAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
            }
        } else {
            [UIAlertView showAlertViewForErrorString:@"Please add a Facebook Account to this device"
                                            delegate:nil];
        }
    }
}

- (IBAction)toggleTwitter:(UIButton *)button {
    [[MRSLEventManager sharedManager] track:@"Tapped Toggle Twitter"
                                 properties:@{@"view": @"MRSLCreateMorselViewController",
                                              @"morsel_id": NSNullIfNil(_morsel.morselID)}];
    MRSLUser *currentUser = [MRSLUser currentUser];

    if ([currentUser twitter_username]) {
        [[MRSLEventManager sharedManager] track:@"User Already Authorized with Twitter"
                                     properties:@{@"view": @"MRSLCreateMorselViewController",
                                                  @"morsel_id": NSNullIfNil(_morsel.morselID)}];
        //  api already has a token, so just toggle the button
        [button setSelected:!button.selected];
    } else {
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
            ACAccountStore *accountStore = [[ACAccountStore alloc] init];
            //  Get a list of their Twitter accounts
            NSArray *twitterAccounts = [accountStore accountsWithAccountType:[accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter]];

            if ([twitterAccounts count] == 0) {
                //  Request to grab the accounts
                MRSLSocialService *socialService = [[MRSLSocialService alloc] init];
                __weak typeof(self) weakSelf = self;
                [socialService requestReadAndWriteForTwitterAccountsWithBlock:^(BOOL granted, NSError *error) {
                    __strong typeof(weakSelf) strongSelf = weakSelf;
                    [strongSelf showActionSheetWithAccountsForAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
                }];
            } else {
                [self showActionSheetWithAccountsForAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
            }
        } else {
            [UIAlertView showAlertViewForErrorString:@"Please add a Twitter Account to this device"
                                            delegate:nil];
        }
    }
}

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
        [actionSheet showInView:self.view];
    });
}

- (IBAction)toggleInstagram:(UIButton *)button {
    [[MRSLEventManager sharedManager] track:@"Tapped Toggle Instagram"
                                 properties:@{@"view": @"MRSLCreateMorselViewController",
                                              @"morsel_id": NSNullIfNil(_morsel.morselID)}];

    if ([button isSelected]) {
        [button setSelected:NO];
    } else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"instagram://app"]]) {
        if (_morsel.morselPhoto) {
            [button setSelected:YES];
        } else {
            [UIAlertView showAlertViewForErrorString:@"Please add a photo to post to Instagram"
                                            delegate:nil];
        }
    } else {
        [UIAlertView showAlertViewForErrorString:@"Please install Instagram to post your Morsel there"
                                        delegate:nil];
    }
}

- (void)sendToInstagram {
    [[MRSLEventManager sharedManager] track:@"Presented Instagram Document Interaction Controller"
                                 properties:@{@"view": @"MRSLCreateMorselViewController",
                                              @"morsel_id": NSNullIfNil(_morsel.morselID)}];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *photoFilePath = [NSString stringWithFormat:@"%@/%@",[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"],@"tempinstgramphoto.igo"];
        [_morsel.morselPhoto writeToFile:photoFilePath atomically:YES];

        _documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:photoFilePath]];
        _documentInteractionController.UTI = @"com.instagram.exclusivegram";
        _documentInteractionController.delegate = self;
        NSString *socialMessage = [_morsel socialMessage];
        if (socialMessage) {
            _documentInteractionController.annotation = [NSDictionary dictionaryWithObject:socialMessage
                                                                                    forKey:@"InstagramCaption"];
        }
        [_documentInteractionController presentOpenInMenuFromRect:CGRectZero
                                                           inView:self.view
                                                         animated:YES];
    });
}

#pragma mark - UIActionSheetDelegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == CreateMorselActionSheetFacebookAccounts) {
        if (buttonIndex == [_facebookAccounts count]) return;
        MRSLSocialService *socialService = [[MRSLSocialService alloc] init];
        __weak typeof(self) weakSelf = self;
        [socialService requestReadAndWriteForFacebookAccountsWithBlock:^(BOOL granted, NSError *error) {
            if (error) {
                [UIAlertView showAlertViewForError:error
                                          delegate:nil];
            } else {
                ACAccountStore *accountStore = [[ACAccountStore alloc] init];
                //  Get _facebookAccounts again after access has been granted, otherwise the account's credential will be nil
                _facebookAccounts = [accountStore accountsWithAccountType:[accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook]];
                ACAccount *selectedAccount = _facebookAccounts[buttonIndex];
                [_appDelegate.morselApiService createFacebookAuthorizationWithToken:[[selectedAccount credential] oauthToken]
                                                                            forUser:[MRSLUser currentUser]
                                                                            success:^(id responseObject) {
                                                                                [_appDelegate.morselApiService updateUser:[MRSLUser currentUser] success:^(id userResponseObject) {
                                                                                    [[MRSLEventManager sharedManager] track:@"User Authorized with Facebook"
                                                                                                                 properties:@{@"view": @"MRSLCreateMorselViewController",
                                                                                                                              @"morsel_id": NSNullIfNil(_morsel.morselID)}];
                                                                                    __strong __typeof(weakSelf) strongSelf = weakSelf;
                                                                                    [strongSelf->_facebookButton setEnabled:YES];
                                                                                    [strongSelf->_facebookButton setSelected:!strongSelf->_facebookButton.selected];
                                                                                } failure:^(NSError *error) {
                                                                                    [[MRSLEventManager sharedManager] track:@"User Unable to Authorize with Facebook"
                                                                                                                 properties:@{@"view": @"MRSLCreateMorselViewController",
                                                                                                                              @"morsel_id": NSNullIfNil(_morsel.morselID)}];
                                                                                    __strong __typeof(weakSelf) strongSelf = weakSelf;
                                                                                    [strongSelf->_facebookButton setEnabled:YES];
                                                                                    [UIAlertView showAlertViewForError:error
                                                                                                              delegate:nil];
                                                                                }];
                                                                            } failure:^(NSError *error) {
                                                                                [[MRSLEventManager sharedManager] track:@"User Unable to Authorize with Facebook"
                                                                                                             properties:@{@"view": @"MRSLCreateMorselViewController",
                                                                                                                          @"morsel_id": NSNullIfNil(_morsel.morselID)}];
                                                                                __strong __typeof(weakSelf) strongSelf = weakSelf;
                                                                                [strongSelf->_facebookButton setEnabled:YES];
                                                                                [UIAlertView showAlertViewForError:error
                                                                                                          delegate:nil];
                                                                            }];
            }
        }];
    } else if (actionSheet.tag == CreateMorselActionSheetTwitterAccounts) {
        if (buttonIndex == [_twitterAccounts count]) return;
        ACAccount *selectedAccount = _twitterAccounts[buttonIndex];
        MRSLSocialService *socialService = [[MRSLSocialService alloc] init];
        [_twitterButton setEnabled:NO];

        [socialService performReverseAuthForTwitterAccount:selectedAccount
                                                 withBlock:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                     NSDictionary *params = [NSURL ab_parseURLQueryString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
                                                     __weak typeof(self) weakSelf = self;
                                                     [_appDelegate.morselApiService createTwitterAuthorizationWithToken:params[@"oauth_token"]
                                                                                                                 secret:params[@"oauth_token_secret"]
                                                                                                                forUser:[MRSLUser currentUser]
                                                                                                                success:^(id responseObject) {
                                                                                                                    [_appDelegate.morselApiService updateUser:[MRSLUser currentUser] success:^(id userResponseObject) {
                                                                                                                        [[MRSLEventManager sharedManager] track:@"User Authorized with Twitter"
                                                                                                                                                     properties:@{@"view": @"MRSLCreateMorselViewController",
                                                                                                                                                                  @"morsel_id": NSNullIfNil(_morsel.morselID)}];
                                                                                                                        __strong __typeof(weakSelf) strongSelf = weakSelf;
                                                                                                                        [strongSelf->_twitterButton setEnabled:YES];
                                                                                                                        [strongSelf->_twitterButton setSelected:!strongSelf->_twitterButton.selected];
                                                                                                                    } failure:^(NSError *error) {
                                                                                                                        [[MRSLEventManager sharedManager] track:@"User Unable to Authorize with Twitter"
                                                                                                                                                     properties:@{@"view": @"MRSLCreateMorselViewController",
                                                                                                                                                                  @"morsel_id": NSNullIfNil(_morsel.morselID)}];
                                                                                                                        __strong __typeof(weakSelf) strongSelf = weakSelf;
                                                                                                                        [strongSelf->_twitterButton setEnabled:YES];
                                                                                                                        [UIAlertView showAlertViewForError:error
                                                                                                                                                  delegate:nil];
                                                                                                                    }];
                                                                                                                } failure:^(NSError *error) {
                                                                                                                    [[MRSLEventManager sharedManager] track:@"User Unable to Authorize with Twitter"
                                                                                                                                                 properties:@{@"view": @"MRSLCreateMorselViewController",
                                                                                                                                                              @"morsel_id": NSNullIfNil(_morsel.morselID)}];
                                                                                                                    __strong __typeof(weakSelf) strongSelf = weakSelf;
                                                                                                                    [strongSelf->_twitterButton setEnabled:YES];
                                                                                                                    [UIAlertView showAlertViewForError:error
                                                                                                                                              delegate:nil];
                                                                                                                }];
                                                 }];
    }
}

#pragma mark - UIDocumentInteractionControllerDelegate Methods

- (void)documentInteractionController:(UIDocumentInteractionController *)controller
        willBeginSendingToApplication:(NSString *)application {
    [[MRSLEventManager sharedManager] track:@"Tapped Send to Instagram"
                                 properties:@{@"view": @"MRSLCreateMorselViewController",
                                              @"morsel_id": NSNullIfNil(_morsel.morselID),
                                              @"morsel_social_message": _morsel.socialMessage}];
    [self.presentingViewController dismissViewControllerAnimated:YES
                                                      completion:nil];
}

- (void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller {
    [self.presentingViewController dismissViewControllerAnimated:YES
                                                      completion:nil];
}

@end
