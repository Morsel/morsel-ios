#import "_MRSLPost.h"

@interface MRSLPost : _MRSLPost {}

- (void)setWithDictionary:(NSDictionary *)dictionary
                inContext:(NSManagedObjectContext *)context;

- (void)addMorsel:(MRSLMorsel *)morsel;

@end
