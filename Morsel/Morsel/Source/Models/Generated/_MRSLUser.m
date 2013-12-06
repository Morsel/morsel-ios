// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MRSLUser.m instead.

#import "_MRSLUser.h"

const struct MRSLUserAttributes MRSLUserAttributes = {
	.emailAddress = @"emailAddress",
};

const struct MRSLUserRelationships MRSLUserRelationships = {
};

const struct MRSLUserFetchedProperties MRSLUserFetchedProperties = {
};

@implementation MRSLUserID
@end

@implementation _MRSLUser

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"MRSLUser" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"MRSLUser";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"MRSLUser" inManagedObjectContext:moc_];
}

- (MRSLUserID*)objectID {
	return (MRSLUserID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic emailAddress;











@end
