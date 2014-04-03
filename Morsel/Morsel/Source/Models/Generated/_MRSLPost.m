// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MRSLPost.m instead.

#import "_MRSLPost.h"

const struct MRSLPostAttributes MRSLPostAttributes = {
	.creationDate = @"creationDate",
	.draft = @"draft",
	.feedItemID = @"feedItemID",
	.lastUpdatedDate = @"lastUpdatedDate",
	.postID = @"postID",
	.primary_morsel_id = @"primary_morsel_id",
	.title = @"title",
	.total_comment_count = @"total_comment_count",
	.total_like_count = @"total_like_count",
};

const struct MRSLPostRelationships MRSLPostRelationships = {
	.creator = @"creator",
	.morsels = @"morsels",
};

const struct MRSLPostFetchedProperties MRSLPostFetchedProperties = {
};

@implementation MRSLPostID
@end

@implementation _MRSLPost

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"MRSLPost" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"MRSLPost";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"MRSLPost" inManagedObjectContext:moc_];
}

- (MRSLPostID*)objectID {
	return (MRSLPostID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"draftValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"draft"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"feedItemIDValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"feedItemID"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"postIDValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"postID"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"primary_morsel_idValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"primary_morsel_id"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"total_comment_countValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"total_comment_count"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"total_like_countValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"total_like_count"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic creationDate;






@dynamic draft;



- (BOOL)draftValue {
	NSNumber *result = [self draft];
	return [result boolValue];
}

- (void)setDraftValue:(BOOL)value_ {
	[self setDraft:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveDraftValue {
	NSNumber *result = [self primitiveDraft];
	return [result boolValue];
}

- (void)setPrimitiveDraftValue:(BOOL)value_ {
	[self setPrimitiveDraft:[NSNumber numberWithBool:value_]];
}





@dynamic feedItemID;



- (int32_t)feedItemIDValue {
	NSNumber *result = [self feedItemID];
	return [result intValue];
}

- (void)setFeedItemIDValue:(int32_t)value_ {
	[self setFeedItemID:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveFeedItemIDValue {
	NSNumber *result = [self primitiveFeedItemID];
	return [result intValue];
}

- (void)setPrimitiveFeedItemIDValue:(int32_t)value_ {
	[self setPrimitiveFeedItemID:[NSNumber numberWithInt:value_]];
}





@dynamic lastUpdatedDate;






@dynamic postID;



- (int32_t)postIDValue {
	NSNumber *result = [self postID];
	return [result intValue];
}

- (void)setPostIDValue:(int32_t)value_ {
	[self setPostID:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitivePostIDValue {
	NSNumber *result = [self primitivePostID];
	return [result intValue];
}

- (void)setPrimitivePostIDValue:(int32_t)value_ {
	[self setPrimitivePostID:[NSNumber numberWithInt:value_]];
}





@dynamic primary_morsel_id;



- (int32_t)primary_morsel_idValue {
	NSNumber *result = [self primary_morsel_id];
	return [result intValue];
}

- (void)setPrimary_morsel_idValue:(int32_t)value_ {
	[self setPrimary_morsel_id:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitivePrimary_morsel_idValue {
	NSNumber *result = [self primitivePrimary_morsel_id];
	return [result intValue];
}

- (void)setPrimitivePrimary_morsel_idValue:(int32_t)value_ {
	[self setPrimitivePrimary_morsel_id:[NSNumber numberWithInt:value_]];
}





@dynamic title;






@dynamic total_comment_count;



- (int32_t)total_comment_countValue {
	NSNumber *result = [self total_comment_count];
	return [result intValue];
}

- (void)setTotal_comment_countValue:(int32_t)value_ {
	[self setTotal_comment_count:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveTotal_comment_countValue {
	NSNumber *result = [self primitiveTotal_comment_count];
	return [result intValue];
}

- (void)setPrimitiveTotal_comment_countValue:(int32_t)value_ {
	[self setPrimitiveTotal_comment_count:[NSNumber numberWithInt:value_]];
}





@dynamic total_like_count;



- (int32_t)total_like_countValue {
	NSNumber *result = [self total_like_count];
	return [result intValue];
}

- (void)setTotal_like_countValue:(int32_t)value_ {
	[self setTotal_like_count:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveTotal_like_countValue {
	NSNumber *result = [self primitiveTotal_like_count];
	return [result intValue];
}

- (void)setPrimitiveTotal_like_countValue:(int32_t)value_ {
	[self setPrimitiveTotal_like_count:[NSNumber numberWithInt:value_]];
}





@dynamic creator;

	

@dynamic morsels;

	
- (NSMutableSet*)morselsSet {
	[self willAccessValueForKey:@"morsels"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"morsels"];
  
	[self didAccessValueForKey:@"morsels"];
	return result;
}
	






@end
