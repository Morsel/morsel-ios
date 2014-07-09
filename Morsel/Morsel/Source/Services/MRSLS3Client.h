//
//  MRSLS3Client.h
//  Morsel
//
//  Created by Marty Trzpit on 7/7/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"

@interface MRSLS3Client : AFHTTPRequestOperationManager

+ (instancetype)sharedClient;

@end
