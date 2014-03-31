#import "MRSLNotification.h"
#import "MRSLActivity.h"

@implementation MRSLNotification

- (void)didImport:(id)data {
    if ([data[@"payload_type"] isEqualToString:@"Activity"]) [self importActivity:data[@"payload"]];
}


#pragma mark - Private Methods

- (void)importActivity:(NSDictionary *)activityDictionary {
    if (![activityDictionary isEqual:[NSNull null]]) {
        MRSLActivity *activity = [MRSLActivity MR_findFirstByAttribute:MRSLActivityAttributes.activityID
                                                       withValue:activityDictionary[@"id"]
                                                       inContext:self.managedObjectContext];
        if (!activity) activity = [MRSLActivity MR_createInContext:self.managedObjectContext];
        [activity MR_importValuesForKeysWithObject:activityDictionary];
        [activity setNotification:self];
    }
}

@end
