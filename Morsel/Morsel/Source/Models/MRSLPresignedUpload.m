#import "MRSLPresignedUpload.h"

@interface MRSLPresignedUpload ()

@end


@implementation MRSLPresignedUpload

- (NSDictionary *)params {
    return @{
             @"key": NSNullIfNil(self.key),
             @"AWSAccessKeyId": NSNullIfNil(self.awsAccessKeyId),
             @"policy": NSNullIfNil(self.policy),
             @"signature": NSNullIfNil(self.signature),
             @"acl": NSNullIfNil(self.acl),
             @"success_action_status": NSNullIfNil(self.successActionStatus),
             };
}

@end
