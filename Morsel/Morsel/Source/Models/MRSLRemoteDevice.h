#import "_MRSLRemoteDevice.h"

@interface MRSLRemoteDevice : _MRSLRemoteDevice {}

+ (MRSLRemoteDevice *)currentRemoteDevice;

- (void)API_deleteWithSuccess:(MRSLAPISuccessBlock)successOrNil
                      failure:(MRSLFailureBlock)failureOrNil;

@end
