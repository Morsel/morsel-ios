#import "_MRSLMorsel.h"

@interface MRSLMorsel : _MRSLMorsel {}

- (void)setWithDictionary:(NSDictionary *)dictionary
                inContext:(NSManagedObjectContext *)context;

- (NSURLRequest *)morselPictureURLRequest;

@end
