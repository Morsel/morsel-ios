//
//  MRSLFactory+User.m
//  Morsel
//
//  Created by Marty Trzpit on 3/31/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLFactory+User.h"

#import "MRSLUser.h"

@implementation MRSLFactory (User)

+ (MRSLUser *)user {
    MRSLUser *user = [MRSLUser MR_createEntity];

    [user setFirst_name:@"Turd"];
    [user setLast_name:@"Ferguson"];
    [user setUsername:@"turdferg"];

    return user;
}

@end
