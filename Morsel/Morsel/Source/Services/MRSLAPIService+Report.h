//
//  MRSLAPIService+Report.h
//  Morsel
//
//  Created by Javier Otero on 8/8/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLAPIService.h"

#import "MRSLReportable.h"

@interface MRSLAPIService (Report)

- (void)sendReportable:(NSManagedObject <MRSLReportable> *)reportable
               success:(MRSLSuccessBlock)successOrNil
               failure:(MRSLFailureBlock)failureOrNil;

@end
