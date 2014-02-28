//
//  MRSLSpecUtil.h
//  Morsel
//
//  Created by Javier Otero on 2/26/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MRSLSpecUtil : NSObject

+ (void)stubMorselAPIRequestsWithJSONFileName:(NSString *)fileName
                                forRequestPath:(NSString *)urlParametersToMatch;

@end
