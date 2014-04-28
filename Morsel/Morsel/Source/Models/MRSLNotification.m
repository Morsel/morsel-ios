#import "MRSLNotification.h"
#import "MRSLActivity.h"

@implementation MRSLNotification

- (void)didImport:(id)data {
    if ([data[@"payload_type"] isEqualToString:@"Activity"]) [self importActivity:data[@"payload"]];
    
    if (![data[@"created_at"] isEqual:[NSNull null]]) {
        NSString *dateString = data[@"created_at"];
        self.creationDate = [_appDelegate.defaultDateFormatter dateFromString:dateString];
    }
}

#pragma mark - Private Methods

- (void)importActivity:(NSDictionary *)activityDictionary {
    if (![activityDictionary isEqual:[NSNull null]]) {
        NSDictionary *activityImportDictionary = activityDictionary[@"payload"] ?: activityDictionary;
        MRSLActivity *activity = [MRSLActivity MR_findFirstByAttribute:MRSLActivityAttributes.activityID
                                                       withValue:activityImportDictionary[@"id"]
                                                       inContext:self.managedObjectContext];
        if (!activity) activity = [MRSLActivity MR_createInContext:self.managedObjectContext];
        [activity MR_importValuesForKeysWithObject:activityImportDictionary];
        [self setActivity:activity];
        [activity setNotification:self];
    }
}

@end
