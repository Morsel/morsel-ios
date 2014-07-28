// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MRSLUser.m instead.

#import "_MRSLUser.h"

const struct MRSLUserAttributes MRSLUserAttributes = {
	.auth_token = @"auth_token",
	.auto_follow = @"auto_follow",
	.bio = @"bio",
	.creationDate = @"creationDate",
	.dateFollowed = @"dateFollowed",
	.draft_count = @"draft_count",
	.email = @"email",
	.facebook_uid = @"facebook_uid",
	.first_name = @"first_name",
	.followed_user_count = @"followed_user_count",
	.follower_count = @"follower_count",
	.following = @"following",
	.isUploading = @"isUploading",
	.last_name = @"last_name",
	.liked_item_count = @"liked_item_count",
	.morsel_count = @"morsel_count",
	.passwordSet = @"passwordSet",
	.photo_processing = @"photo_processing",
	.professional = @"professional",
	.profilePhotoFull = @"profilePhotoFull",
	.profilePhotoLarge = @"profilePhotoLarge",
	.profilePhotoThumb = @"profilePhotoThumb",
	.profilePhotoURL = @"profilePhotoURL",
	.staff = @"staff",
	.title = @"title",
	.twitter_username = @"twitter_username",
	.userID = @"userID",
	.username = @"username",
};

const struct MRSLUserRelationships MRSLUserRelationships = {
	.activities = @"activities",
	.activitiesAsSubject = @"activitiesAsSubject",
	.comments = @"comments",
	.morsels = @"morsels",
	.places = @"places",
	.presignedUpload = @"presignedUpload",
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
	
	if ([key isEqualToString:@"auto_followValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"auto_follow"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"draft_countValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"draft_count"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"followed_user_countValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"followed_user_count"];
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
	if ([key isEqualToString:@"isUploadingValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isUploading"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"liked_item_countValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"liked_item_count"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"morsel_countValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"morsel_count"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"passwordSetValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"passwordSet"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"photo_processingValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"photo_processing"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"professionalValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"professional"];
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






@dynamic auto_follow;



- (BOOL)auto_followValue {
	NSNumber *result = [self auto_follow];
	return [result boolValue];
}

- (void)setAuto_followValue:(BOOL)value_ {
	[self setAuto_follow:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveAuto_followValue {
	NSNumber *result = [self primitiveAuto_follow];
	return [result boolValue];
}

- (void)setPrimitiveAuto_followValue:(BOOL)value_ {
	[self setPrimitiveAuto_follow:[NSNumber numberWithBool:value_]];
}





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






@dynamic followed_user_count;



- (int32_t)followed_user_countValue {
	NSNumber *result = [self followed_user_count];
	return [result intValue];
}

- (void)setFollowed_user_countValue:(int32_t)value_ {
	[self setFollowed_user_count:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveFollowed_user_countValue {
	NSNumber *result = [self primitiveFollowed_user_count];
	return [result intValue];
}

- (void)setPrimitiveFollowed_user_countValue:(int32_t)value_ {
	[self setPrimitiveFollowed_user_count:[NSNumber numberWithInt:value_]];
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





@dynamic isUploading;



- (BOOL)isUploadingValue {
	NSNumber *result = [self isUploading];
	return [result boolValue];
}

- (void)setIsUploadingValue:(BOOL)value_ {
	[self setIsUploading:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsUploadingValue {
	NSNumber *result = [self primitiveIsUploading];
	return [result boolValue];
}

- (void)setPrimitiveIsUploadingValue:(BOOL)value_ {
	[self setPrimitiveIsUploading:[NSNumber numberWithBool:value_]];
}





@dynamic last_name;






@dynamic liked_item_count;



- (int32_t)liked_item_countValue {
	NSNumber *result = [self liked_item_count];
	return [result intValue];
}

- (void)setLiked_item_countValue:(int32_t)value_ {
	[self setLiked_item_count:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveLiked_item_countValue {
	NSNumber *result = [self primitiveLiked_item_count];
	return [result intValue];
}

- (void)setPrimitiveLiked_item_countValue:(int32_t)value_ {
	[self setPrimitiveLiked_item_count:[NSNumber numberWithInt:value_]];
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





@dynamic passwordSet;



- (BOOL)passwordSetValue {
	NSNumber *result = [self passwordSet];
	return [result boolValue];
}

- (void)setPasswordSetValue:(BOOL)value_ {
	[self setPasswordSet:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitivePasswordSetValue {
	NSNumber *result = [self primitivePasswordSet];
	return [result boolValue];
}

- (void)setPrimitivePasswordSetValue:(BOOL)value_ {
	[self setPrimitivePasswordSet:[NSNumber numberWithBool:value_]];
}





@dynamic photo_processing;



- (BOOL)photo_processingValue {
	NSNumber *result = [self photo_processing];
	return [result boolValue];
}

- (void)setPhoto_processingValue:(BOOL)value_ {
	[self setPhoto_processing:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitivePhoto_processingValue {
	NSNumber *result = [self primitivePhoto_processing];
	return [result boolValue];
}

- (void)setPrimitivePhoto_processingValue:(BOOL)value_ {
	[self setPrimitivePhoto_processing:[NSNumber numberWithBool:value_]];
}





@dynamic professional;



- (BOOL)professionalValue {
	NSNumber *result = [self professional];
	return [result boolValue];
}

- (void)setProfessionalValue:(BOOL)value_ {
	[self setProfessional:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveProfessionalValue {
	NSNumber *result = [self primitiveProfessional];
	return [result boolValue];
}

- (void)setPrimitiveProfessionalValue:(BOOL)value_ {
	[self setPrimitiveProfessional:[NSNumber numberWithBool:value_]];
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

	
- (NSMutableSet*)activitiesSet {
	[self willAccessValueForKey:@"activities"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"activities"];
  
	[self didAccessValueForKey:@"activities"];
	return result;
}
	

@dynamic activitiesAsSubject;

	
- (NSMutableSet*)activitiesAsSubjectSet {
	[self willAccessValueForKey:@"activitiesAsSubject"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"activitiesAsSubject"];
  
	[self didAccessValueForKey:@"activitiesAsSubject"];
	return result;
}
	

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
	

@dynamic places;

	
- (NSMutableSet*)placesSet {
	[self willAccessValueForKey:@"places"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"places"];
  
	[self didAccessValueForKey:@"places"];
	return result;
}
	

@dynamic presignedUpload;

	

@dynamic tags;

	
- (NSMutableSet*)tagsSet {
	[self willAccessValueForKey:@"tags"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"tags"];
  
	[self didAccessValueForKey:@"tags"];
	return result;
}
	






@end
