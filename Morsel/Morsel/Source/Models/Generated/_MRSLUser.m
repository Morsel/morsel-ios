// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MRSLUser.m instead.

#import "_MRSLUser.h"

const struct MRSLUserAttributes MRSLUserAttributes = {
	.auth_token = @"auth_token",
	.bio = @"bio",
	.creationDate = @"creationDate",
	.dateFollowed = @"dateFollowed",
	.draft_count = @"draft_count",
	.email = @"email",
	.facebook_uid = @"facebook_uid",
	.first_name = @"first_name",
	.followed_users_count = @"followed_users_count",
	.follower_count = @"follower_count",
	.following = @"following",
	.industryType = @"industryType",
	.last_name = @"last_name",
	.liked_items_count = @"liked_items_count",
	.morsel_count = @"morsel_count",
	.profilePhotoFull = @"profilePhotoFull",
	.profilePhotoLarge = @"profilePhotoLarge",
	.profilePhotoThumb = @"profilePhotoThumb",
	.profilePhotoURL = @"profilePhotoURL",
	.staff = @"staff",
	.twitter_username = @"twitter_username",
	.userID = @"userID",
	.username = @"username",
};

const struct MRSLUserRelationships MRSLUserRelationships = {
	.activities = @"activities",
	.comments = @"comments",
	.morsels = @"morsels",
	.tags = @"tags",
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
	if ([key isEqualToString:@"followed_users_countValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"followed_users_count"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"follower_countValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"follower_count"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"followingValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"following"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"industryTypeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"industryType"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"liked_items_countValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"liked_items_count"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"morsel_countValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"morsel_count"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"staffValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"staff"];
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






@dynamic dateFollowed;






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






@dynamic followed_users_count;



- (int32_t)followed_users_countValue {
	NSNumber *result = [self followed_users_count];
	return [result intValue];
}

- (void)setFollowed_users_countValue:(int32_t)value_ {
	[self setFollowed_users_count:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveFollowed_users_countValue {
	NSNumber *result = [self primitiveFollowed_users_count];
	return [result intValue];
}

- (void)setPrimitiveFollowed_users_countValue:(int32_t)value_ {
	[self setPrimitiveFollowed_users_count:[NSNumber numberWithInt:value_]];
}





@dynamic follower_count;



- (int32_t)follower_countValue {
	NSNumber *result = [self follower_count];
	return [result intValue];
}

- (void)setFollower_countValue:(int32_t)value_ {
	[self setFollower_count:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveFollower_countValue {
	NSNumber *result = [self primitiveFollower_count];
	return [result intValue];
}

- (void)setPrimitiveFollower_countValue:(int32_t)value_ {
	[self setPrimitiveFollower_count:[NSNumber numberWithInt:value_]];
}





@dynamic following;



- (BOOL)followingValue {
	NSNumber *result = [self following];
	return [result boolValue];
}

- (void)setFollowingValue:(BOOL)value_ {
	[self setFollowing:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveFollowingValue {
	NSNumber *result = [self primitiveFollowing];
	return [result boolValue];
}

- (void)setPrimitiveFollowingValue:(BOOL)value_ {
	[self setPrimitiveFollowing:[NSNumber numberWithBool:value_]];
}





@dynamic industryType;



- (int16_t)industryTypeValue {
	NSNumber *result = [self industryType];
	return [result shortValue];
}

- (void)setIndustryTypeValue:(int16_t)value_ {
	[self setIndustryType:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveIndustryTypeValue {
	NSNumber *result = [self primitiveIndustryType];
	return [result shortValue];
}

- (void)setPrimitiveIndustryTypeValue:(int16_t)value_ {
	[self setPrimitiveIndustryType:[NSNumber numberWithShort:value_]];
}





@dynamic last_name;






@dynamic liked_items_count;



- (int32_t)liked_items_countValue {
	NSNumber *result = [self liked_items_count];
	return [result intValue];
}

- (void)setLiked_items_countValue:(int32_t)value_ {
	[self setLiked_items_count:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveLiked_items_countValue {
	NSNumber *result = [self primitiveLiked_items_count];
	return [result intValue];
}

- (void)setPrimitiveLiked_items_countValue:(int32_t)value_ {
	[self setPrimitiveLiked_items_count:[NSNumber numberWithInt:value_]];
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






@dynamic staff;



- (BOOL)staffValue {
	NSNumber *result = [self staff];
	return [result boolValue];
}

- (void)setStaffValue:(BOOL)value_ {
	[self setStaff:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveStaffValue {
	NSNumber *result = [self primitiveStaff];
	return [result boolValue];
}

- (void)setPrimitiveStaffValue:(BOOL)value_ {
	[self setPrimitiveStaff:[NSNumber numberWithBool:value_]];
}





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
	

@dynamic morsels;

	
- (NSMutableSet*)morselsSet {
	[self willAccessValueForKey:@"morsels"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"morsels"];
  
	[self didAccessValueForKey:@"morsels"];
	return result;
}
	

@dynamic tags;

	
- (NSMutableSet*)tagsSet {
	[self willAccessValueForKey:@"tags"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"tags"];
  
	[self didAccessValueForKey:@"tags"];
	return result;
}
	






@end
