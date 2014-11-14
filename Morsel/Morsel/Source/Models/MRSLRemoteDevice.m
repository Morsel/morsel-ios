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
    objectInfoJSON[@"notification_settings"][@"notify_item_comment"] = self.notify_item_commentValue ? @"true" : @"false";
    objectInfoJSON[@"notification_settings"][@"notify_morsel_like"] = self.notify_morsel_likeValue ? @"true" : @"false";
    objectInfoJSON[@"notification_settings"][@"notify_morsel_morsel_user_tag"] = self.notify_morsel_morsel_user_tagValue ? @"true" : @"false";
    objectInfoJSON[@"notification_settings"][@"notify_user_follow"] = self.notify_user_followValue ? @"true" : @"false";
    objectInfoJSON[@"notification_settings"][@"notify_tagged_morsel_item_comment"] = self.notify_tagged_morsel_item_commentValue ? @"true" : @"false";
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

- (void)API_updateWithSuccess:(MRSLAPISuccessBlock)successOrNil failure:(MRSLFailureBlock)failureOrNil {
    [_appDelegate.apiService updateUserDevice:self
                                      success:successOrNil
                                      failure:failureOrNil];
}

- (void)API_deleteWithSuccess:(MRSLAPISuccessBlock)successOrNil
                      failure:(MRSLFailureBlock)failureOrNil {
    [_appDelegate.apiService deleteUserDevice:self
                                      success:successOrNil
                                      failure:failureOrNil];
}

#pragma mark - MagicalRecord

- (void)didImport:(id)data {
    if (![data[@"created_at"] isEqual:[NSNull null]]) {
        NSString *dateString = data[@"created_at"];
        self.creationDate = [_appDelegate.defaultDateFormatter dateFromString:dateString];
    }
    if (![data[@"notification_settings"] isEqual:[NSNull null]]) {
        [[data[@"notification_settings"] allKeys] enumerateObjectsUsingBlock:^(NSString *notificationSettingKey, NSUInteger idx, BOOL *stop) {
            NSRange notificationSettingStringRange = NSMakeRange(1, [notificationSettingKey length] - 1);
            NSString *notificationSettingString = [notificationSettingKey substringWithRange:notificationSettingStringRange];
            NSString *setSettingSelectorName = [NSString stringWithFormat:@"setN%@:", notificationSettingString];
            SEL setSettingSelector = NSSelectorFromString(setSettingSelectorName);
            if ([self respondsToSelector:setSettingSelector]) {
                ((void (*)(id, SEL, NSNumber *))[self methodForSelector:setSettingSelector])(self, setSettingSelector, @([data[@"notification_settings"][notificationSettingKey] boolValue]));
            }
        }];
    }
}

@end
