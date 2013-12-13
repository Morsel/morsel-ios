#import "MRSLUser.h"


@interface MRSLUser ()

@end


@implementation MRSLUser

#pragma mark - Instance Methods

- (NSString *)fullName
{
    return [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
}

- (UserOccupationType)occupationTypeRaw
{
    return (UserOccupationType)[self.occupationType intValue];
}

- (void)addPost:(MRSLPost *)post
{
    [self.postsSet addObject:post];
}

- (void)setOccupationTypeRaw:(UserOccupationType)type
{
    [self setOccupationType:[NSNumber numberWithInt:type]];
}

#pragma mark - Private Methods

+(NSSet *)keyPathsForValuesAffectingOccupationTypeRaw
{
    return [NSSet setWithObject:@"occupationType"];
}

@end
