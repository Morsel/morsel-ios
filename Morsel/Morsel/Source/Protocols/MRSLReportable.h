//
//  MRSLReportable.h
//  Morsel
//
//  Created by Javier Otero on 8/8/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MRSLReportable <NSObject>

@required
- (NSString *)reportableUrlString;

- (void)API_reportWithSuccess:(MRSLSuccessBlock)successOrNil
                      failure:(MRSLFailureBlock)failureOrNil;

@end
