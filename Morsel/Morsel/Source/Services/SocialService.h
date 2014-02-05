//
//  SocialService.h
//  Morsel
//
//  Created by Marty Trzpit on 1/30/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accounts/Accounts.h>

@class ACAccount;
@class SLRequestHandler;

@interface SocialService : NSObject

- (void)performReverseAuthForTwitterAccount:(ACAccount *)account withBlock:(MorselDataURLResponseErrorBlock)block;

- (void)requestReadAndWriteForFacebookAccountsWithBlock:(ACAccountStoreRequestAccessCompletionHandler)block;

@end
