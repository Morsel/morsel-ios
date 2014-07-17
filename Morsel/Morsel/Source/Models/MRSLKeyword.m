#import "MRSLKeyword.h"

#import "MRSLTag.h"
#import "MRSLUser.h"

@interface MRSLKeyword ()

@end

@implementation MRSLKeyword

#pragma mark - Class Methods

+ (NSString *)API_identifier {
    return MRSLKeywordAttributes.keywordID;
}

#pragma mark - Instance Methods

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
