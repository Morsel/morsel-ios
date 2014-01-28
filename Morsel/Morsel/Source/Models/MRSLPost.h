#import "_MRSLPost.h"

@interface MRSLPost : _MRSLPost {}

- (BOOL)isDraft;

- (void)setWithDictionary:(NSDictionary *)dictionary;
- (void)addMorsel:(MRSLMorsel *)morsel;
- (void)removeMorsel:(MRSLMorsel *)morsel;

@end
