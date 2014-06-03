#import "MRSLComment.h"

#import "MRSLItem.h"
#import "MRSLUser.h"

@interface MRSLComment ()

@end

@implementation MRSLComment

- (BOOL)deleteableByUser:(MRSLUser *)user {
    // Only the comment creator OR the Item's creator can delete a Comment
    if (user == self.creator) return YES;
    if (user.userID == self.item.creator_id) return YES;
    return NO;
}

- (void)didImport:(id)data {
    if (![data[@"item_id"] isEqual:[NSNull null]]) {
        NSNumber *itemID = data[@"item_id"];
        MRSLItem *potentialItem = [MRSLItem MR_findFirstByAttribute:MRSLItemAttributes.itemID
                                                                withValue:itemID
                                                                inContext:self.managedObjectContext];
        if (potentialItem) {
            self.item = potentialItem;
            [self.item addCommentsObject:self];
        }
    }
    if (![data[@"created_at"] isEqual:[NSNull null]]) {
        NSString *dateString = data[@"created_at"];
        self.creationDate = [_appDelegate.defaultDateFormatter dateFromString:dateString];
    }
    if ([[data[@"commentable_type"] lowercaseString] isEqualToString:@"item"]) [self importItem:data];
}

- (NSDictionary *)objectToJSON {
    NSMutableDictionary *objectInfoJSON = [NSMutableDictionary dictionary];

    if (self.commentDescription) [objectInfoJSON setObject:self.commentDescription
                                                    forKey:@"description"];

    NSDictionary *commentJSON = [NSDictionary dictionaryWithObject:objectInfoJSON
                                                            forKey:@"comment"];

    return commentJSON;
}

- (void)importItem:(NSDictionary *)commentableItemDictionary {
    if (![commentableItemDictionary isEqual:[NSNull null]]) {
        MRSLItem *item = [MRSLItem MR_findFirstByAttribute:MRSLItemAttributes.itemID
                                                             withValue:commentableItemDictionary[@"commentable_id"]
                                                             inContext:self.managedObjectContext];
        if (item) {
            [self setItem:item];
            [item addCommentsObject:self];
        }
    }
}

@end
