#import "MRSLPost.h"


@interface MRSLPost ()

@end


@implementation MRSLPost

- (void)addMorsel:(MRSLMorsel *)morsel
{
    [self.morselsSet addObject:morsel];
}

@end
