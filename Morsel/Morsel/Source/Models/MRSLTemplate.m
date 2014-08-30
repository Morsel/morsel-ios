#import "MRSLTemplate.h"

@implementation MRSLTemplate

#pragma mark - Class Methods

+ (NSString *)API_identifier {
    return MRSLTemplateAttributes.templateID;
}

- (NSArray *)itemsArray {
    NSSortDescriptor *idSort = [NSSortDescriptor sortDescriptorWithKey:@"placeholder_sort_order"
                                                             ascending:YES];
    return [[self.items allObjects] sortedArrayUsingDescriptors:@[idSort]];
}

- (BOOL)isCreateMorselType {
    return (self.templateIDValue == 1);
}

@end
