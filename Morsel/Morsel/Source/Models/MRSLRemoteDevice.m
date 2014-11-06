#import "MRSLRemoteDevice.h"

#import "MRSLAPIService+Remote.h"

@implementation MRSLRemoteDevice

#pragma mark - Additions

+ (NSString *)API_identifier {
    return MRSLRemoteDeviceAttributes.deviceID;
}

- (NSString *)jsonKeyName {
    return @"device";
}

- (NSDictionary *)objectToJSON {
    NSMutableDictionary *objectInfoJSON = [NSMutableDictionary dictionary];
    objectInfoJSON[@"notification_settings"] = [NSMutableDictionary dictionary];
    objectInfoJSON[@"notification_settings"][@"notify_item_comment"] = self.notify_item_comment ? @"true" : @"false";
    objectInfoJSON[@"notification_settings"][@"notify_morsel_like"] = self.notify_morsel_like ? @"true" : @"false";
    objectInfoJSON[@"notification_settings"][@"notify_morsel_morsel_user_tag"] = self.notify_morsel_morsel_user_tag ? @"true" : @"false";
    objectInfoJSON[@"notification_settings"][@"notify_user_follow"] = self.notify_user_follow ? @"true" : @"false";
    return objectInfoJSON;
}

#pragma mark - Class Methods

+ (MRSLRemoteDevice *)currentRemoteDevice {
    NSNumber *currentRemoteDeviceID = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"deviceID"];
    MRSLRemoteDevice *remoteDevice = nil;
    if (currentRemoteDeviceID) {
        remoteDevice = [MRSLRemoteDevice MR_findFirstByAttribute:MRSLRemoteDeviceAttributes.deviceID
                                                       withValue:currentRemoteDeviceID
                                                       inContext:[NSManagedObjectContext MR_defaultContext]];
    }
    return remoteDevice;
}

#pragma mark - API

- (void)API_deleteWithSuccess:(MRSLAPISuccessBlock)successOrNil
                      failure:(MRSLFailureBlock)failureOrNil {
    [_appDelegate.apiService deleteUserDevice:self
                                      success:successOrNil
                                      failure:failureOrNil];
}

#pragma mark - MagicalRecord

- (void)didImport:(id)data {
    if (![data[@"creation_date"] isEqual:[NSNull null]]) {
        NSString *dateString = data[@"creation_date"];
        self.creationDate = [_appDelegate.defaultDateFormatter dateFromString:dateString];
    }
}

@end
