// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MRSLUser.m instead.

#import "_MRSLUser.h"

const struct MRSLUserAttributes MRSLUserAttributes = {
	.auth_token = @"auth_token",
	.bio = @"bio",
	.creationDate = @"creationDate",
	.draft_count = @"draft_count",
	.email = @"email",
	.facebook_uid = @"facebook_uid",
	.first_name = @"first_name",
	.last_name = @"last_name",
	.like_count = @"like_count",
	.morsel_count = @"morsel_count",
	.occupationType = @"occupationType",
	.profilePhoto = @"profilePhoto",
	.profilePhotoURL = @"profilePhotoURL",
	.title = @"title",
	.twitter_username = @"twitter_username",
	.userID = @"userID",
	.username = @"username",
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
	
	if ([key isEqualToString:@"draft_countValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"draft_count"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"like_countValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"like_count"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"morsel_countValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"morsel_count"];
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




@dynamic auth_token;






@dynamic bio;






@dynamic creationDate;






@dynamic draft_count;



- (int16_t)draft_countValue {
	NSNumber *result = [self draft_count];
	return [result shortValue];
}

- (void)setDraft_countValue:(int16_t)value_ {
	[self setDraft_count:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveDraft_countValue {
	NSNumber *result = [self primitiveDraft_count];
	return [result shortValue];
}

- (void)setPrimitiveDraft_countValue:(int16_t)value_ {
	[self setPrimitiveDraft_count:[NSNumber numberWithShort:value_]];
}





@dynamic email;






@dynamic facebook_uid;






@dynamic first_name;






@dynamic last_name;






@dynamic like_count;



- (int16_t)like_countValue {
	NSNumber *result = [self like_count];
	return [result shortValue];
}

- (void)setLike_countValue:(int16_t)value_ {
	[self setLike_count:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveLike_countValue {
	NSNumber *result = [self primitiveLike_count];
	return [result shortValue];
}

- (void)setPrimitiveLike_countValue:(int16_t)value_ {
	[self setPrimitiveLike_count:[NSNumber numberWithShort:value_]];
}





@dynamic morsel_count;



- (int16_t)morsel_countValue {
	NSNumber *result = [self morsel_count];
	return [result shortValue];
}

- (void)setMorsel_countValue:(int16_t)value_ {
	[self setMorsel_count:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveMorsel_countValue {
	NSNumber *result = [self primitiveMorsel_count];
	return [result shortValue];
}

- (void)setPrimitiveMorsel_countValue:(int16_t)value_ {
	[self setPrimitiveMorsel_count:[NSNumber numberWithShort:value_]];
}





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





@dynamic profilePhoto;






@dynamic profilePhotoURL;






@dynamic title;






@dynamic twitter_username;






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





@dynamic username;






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
