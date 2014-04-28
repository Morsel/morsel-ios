#import "MRSLTag.h"

#import "MRSLUser.h"

@interface MRSLTag ()

@end

@implementation MRSLTag

- (void)didImport:(id)data {
    if (![data[@"created_at"] isEqual:[NSNull null]]) {
        NSString *dateString = data[@"created_at"];
        self.creationDate = [_appDelegate.defaultDateFormatter dateFromString:dateString];
    }
    if (![data[@"updated_at"] isEqual:[NSNull null]]) {
        NSString *updateString = data[@"updated_at"];
        self.lastUpdatedDate = [_appDelegate.defaultDateFormatter dateFromString:updateString];
    }
    if ([data[@"taggable_type"] isEqualToString:@"User"]) {
        MRSLUser *user = [MRSLUser MR_findFirstByAttribute:MRSLUserAttributes.userID
                                                 withValue:data[@"taggable_id"]
                                                 inContext:self.managedObjectContext];
        if (user) {
            [user addTagsObject:self];
            [self setUser:user];
        }
    }
}

@end
