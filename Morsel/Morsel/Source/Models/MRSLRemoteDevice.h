#import "_MRSLRemoteDevice.h"

@interface MRSLRemoteDevice : _MRSLRemoteDevice {}

+ (MRSLRemoteDevice *)currentRemoteDevice;

- (void)API_updateWithSuccess:(MRSLAPISuccessBlock)successOrNil
                      failure:(MRSLFailureBlock)failureOrNil;
- (void)API_deleteWithSuccess:(MRSLAPISuccessBlock)successOrNil
                      failure:(MRSLFailureBlock)failureOrNil;

@end
