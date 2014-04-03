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
	.profilePhotoFull = @"profilePhotoFull",
	.profilePhotoLarge = @"profilePhotoLarge",
	.profilePhotoThumb = @"profilePhotoThumb",
	.profilePhotoURL = @"profilePhotoURL",
	.title = @"title",
	.twitter_username = @"twitter_username",
	.userID = @"userID",
	.username = @"username",
};

const struct MRSLUserRelationships MRSLUserRelationships = {
	.activities = @"activities",
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



- (int32_t)draft_countValue {
	NSNumber *result = [self draft_count];
	return [result intValue];
}

- (void)setDraft_countValue:(int32_t)value_ {
	[self setDraft_count:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveDraft_countValue {
	NSNumber *result = [self primitiveDraft_count];
	return [result intValue];
}

- (void)setPrimitiveDraft_countValue:(int32_t)value_ {
	[self setPrimitiveDraft_count:[NSNumber numberWithInt:value_]];
}





@dynamic email;






@dynamic facebook_uid;






@dynamic first_name;






@dynamic last_name;






@dynamic like_count;



- (int32_t)like_countValue {
	NSNumber *result = [self like_count];
	return [result intValue];
}

- (void)setLike_countValue:(int32_t)value_ {
	[self setLike_count:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveLike_countValue {
	NSNumber *result = [self primitiveLike_count];
	return [result intValue];
}

- (void)setPrimitiveLike_countValue:(int32_t)value_ {
	[self setPrimitiveLike_count:[NSNumber numberWithInt:value_]];
}





@dynamic morsel_count;



- (int32_t)morsel_countValue {
	NSNumber *result = [self morsel_count];
	return [result intValue];
}

- (void)setMorsel_countValue:(int32_t)value_ {
	[self setMorsel_count:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveMorsel_countValue {
	NSNumber *result = [self primitiveMorsel_count];
	return [result intValue];
}

- (void)setPrimitiveMorsel_countValue:(int32_t)value_ {
	[self setPrimitiveMorsel_count:[NSNumber numberWithInt:value_]];
}





@dynamic profilePhotoFull;






@dynamic profilePhotoLarge;






@dynamic profilePhotoThumb;






@dynamic profilePhotoURL;






@dynamic title;






@dynamic twitter_username;






@dynamic userID;



- (int32_t)userIDValue {
	NSNumber *result = [self userID];
	return [result intValue];
}

- (void)setUserIDValue:(int32_t)value_ {
	[self setUserID:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveUserIDValue {
	NSNumber *result = [self primitiveUserID];
	return [result intValue];
}

- (void)setPrimitiveUserIDValue:(int32_t)value_ {
	[self setPrimitiveUserID:[NSNumber numberWithInt:value_]];
}





@dynamic username;






@dynamic activities;

	

@dynamic comments;

	
- (NSMutableSet*)commentsSet {
	[self willAccessValueForKey:@"comments"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"comments"];
  
	[self didAccessValueForKey:@"comments"];
	return result;
}
	

@dynamic posts;

	
- (NSMutableSet*)postsSet {
	[self willAccessValueForKey:@"posts"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"posts"];
  
	[self didAccessValueForKey:@"posts"];
	return result;
}
	






@end
