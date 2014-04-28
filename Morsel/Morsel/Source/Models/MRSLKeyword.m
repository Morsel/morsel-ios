#import "MRSLKeyword.h"

#import "MRSLTag.h"
#import "MRSLUser.h"

@interface MRSLKeyword ()

@end

@implementation MRSLKeyword

- (BOOL)isCuisineType {
    return [[self.type lowercaseString] isEqualToString:@"cuisine"];
}

- (BOOL)isSpecialtyType {
    return [[self.type lowercaseString] isEqualToString:@"specialty"];
}

- (BOOL)taggedByCurrentUser {
    return [self.tag.user isCurrentUser];
}

@end
