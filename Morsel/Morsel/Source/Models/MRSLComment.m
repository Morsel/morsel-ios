#import "MRSLComment.h"

#import "MRSLItem.h"
#import "MRSLUser.h"

@interface MRSLComment ()

@end

@implementation MRSLComment

- (void)didImport:(id)data {
    if (![data[@"item_id"] isEqual:[NSNull null]]) {
        NSNumber *itemID = data[@"item_id"];
        MRSLItem *potentialMorsel = [MRSLItem MR_findFirstByAttribute:MRSLItemAttributes.itemID
                                                                withValue:itemID
                                                                inContext:self.managedObjectContext];
        if (potentialMorsel) {
            self.item = potentialMorsel;
            [self.item addCommentsObject:self];
        }
    }
    if (![data[@"created_at"] isEqual:[NSNull null]]) {
        NSString *dateString = data[@"created_at"];
        self.creationDate = [_appDelegate.defaultDateFormatter dateFromString:dateString];
    }
}

- (NSDictionary *)objectToJSON {
    NSMutableDictionary *objectInfoJSON = [NSMutableDictionary dictionary];

    if (self.commentDescription) [objectInfoJSON setObject:self.commentDescription
                                                    forKey:@"description"];

    NSDictionary *commentJSON = [NSDictionary dictionaryWithObject:objectInfoJSON
                                                            forKey:@"comment"];

    return commentJSON;
}

@end
