//
//  Util.m
//  Morsel
//
//  Created by Javier Otero on 1/14/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "Util.h"

@implementation Util

+ (BOOL)validateEmail:(NSString *)emailAddress
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}";
    NSPredicate *emailValidation = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailValidation evaluateWithObject:emailAddress];
}

+ (BOOL)validateUsername:(NSString *)username
{
    BOOL passedRegex = NO;
    BOOL passedLength = ([username length] <= 15);
    
    NSString *usernameRegex = @"[A-Z0-9a-z_]+";
    NSPredicate *usernameValidation = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", usernameRegex];
    
    passedRegex = [usernameValidation evaluateWithObject:username];
    
    return (passedRegex && passedLength);
}

@end
