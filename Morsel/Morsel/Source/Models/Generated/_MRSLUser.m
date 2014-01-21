// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MRSLUser.m instead.

#import "_MRSLUser.h"

const struct MRSLUserAttributes MRSLUserAttributes = {
	.authToken = @"authToken",
	.emailAddress = @"emailAddress",
	.firstName = @"firstName",
	.lastName = @"lastName",
	.likeCount = @"likeCount",
	.morselCount = @"morselCount",
	.occupationTitle = @"occupationTitle",
	.occupationType = @"occupationType",
	.profileImage = @"profileImage",
	.profileImageURL = @"profileImageURL",
	.userID = @"userID",
};

const struct MRSLUserRelationships MRSLUserRelationships = {
	.comments = @"comments",
	.posts = @"posts",
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
	
	if ([key isEqualToString:@"likeCountValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"likeCount"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"morselCountValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"morselCount"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"occupationTypeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"occupationType"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"userIDValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"userID"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic authToken;






@dynamic emailAddress;






@dynamic firstName;






@dynamic lastName;






@dynamic likeCount;



- (int16_t)likeCountValue {
	NSNumber *result = [self likeCount];
	return [result shortValue];
}

- (void)setLikeCountValue:(int16_t)value_ {
	[self setLikeCount:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveLikeCountValue {
	NSNumber *result = [self primitiveLikeCount];
	return [result shortValue];
}

- (void)setPrimitiveLikeCountValue:(int16_t)value_ {
	[self setPrimitiveLikeCount:[NSNumber numberWithShort:value_]];
}





@dynamic morselCount;



- (int16_t)morselCountValue {
	NSNumber *result = [self morselCount];
	return [result shortValue];
}

- (void)setMorselCountValue:(int16_t)value_ {
	[self setMorselCount:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveMorselCountValue {
	NSNumber *result = [self primitiveMorselCount];
	return [result shortValue];
}

- (void)setPrimitiveMorselCountValue:(int16_t)value_ {
	[self setPrimitiveMorselCount:[NSNumber numberWithShort:value_]];
}





@dynamic occupationTitle;






@dynamic occupationType;



- (int16_t)occupationTypeValue {
	NSNumber *result = [self occupationType];
	return [result shortValue];
}

- (void)setOccupationTypeValue:(int16_t)value_ {
	[self setOccupationType:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveOccupationTypeValue {
	NSNumber *result = [self primitiveOccupationType];
	return [result shortValue];
}

- (void)setPrimitiveOccupationTypeValue:(int16_t)value_ {
	[self setPrimitiveOccupationType:[NSNumber numberWithShort:value_]];
}





@dynamic profileImage;






@dynamic profileImageURL;






@dynamic userID;



- (int16_t)userIDValue {
	NSNumber *result = [self userID];
	return [result shortValue];
}

- (void)setUserIDValue:(int16_t)value_ {
	[self setUserID:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveUserIDValue {
	NSNumber *result = [self primitiveUserID];
	return [result shortValue];
}

- (void)setPrimitiveUserIDValue:(int16_t)value_ {
	[self setPrimitiveUserID:[NSNumber numberWithShort:value_]];
}





@dynamic comments;

	
- (NSMutableSet*)commentsSet {
	[self willAccessValueForKey:@"comments"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"comments"];
  
	[self didAccessValueForKey:@"comments"];
	return result;
}
	

@dynamic posts;

	
- (NSMutableOrderedSet*)postsSet {
	[self willAccessValueForKey:@"posts"];
  
	NSMutableOrderedSet *result = (NSMutableOrderedSet*)[self mutableOrderedSetValueForKey:@"posts"];
  
	[self didAccessValueForKey:@"posts"];
	return result;
}
	






@end
