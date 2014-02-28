#import "MRSLComment.h"

#import "MRSLMorsel.h"
#import "MRSLUser.h"

@interface MRSLComment ()

@end

@implementation MRSLComment

- (void)didImport:(id)data {
    if (![data[@"morsel_id"] isEqual:[NSNull null]]) {
        NSNumber *morselID = data[@"morsel_id"];
        MRSLMorsel *potentialMorsel = [MRSLMorsel MR_findFirstByAttribute:MRSLMorselAttributes.morselID
                                                                withValue:morselID
                                                                inContext:self.managedObjectContext];
        if (potentialMorsel) {
            self.morsel = potentialMorsel;
            [self.morsel addCommentsObject:self];
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
