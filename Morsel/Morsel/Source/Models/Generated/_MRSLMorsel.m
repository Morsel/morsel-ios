// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MRSLMorsel.m instead.

#import "_MRSLMorsel.h"

const struct MRSLMorselAttributes MRSLMorselAttributes = {
	.clipboard_mrsl = @"clipboard_mrsl",
	.creationDate = @"creationDate",
	.draft = @"draft",
	.facebook_mrsl = @"facebook_mrsl",
	.feedItemFeatured = @"feedItemFeatured",
	.feedItemID = @"feedItemID",
	.lastUpdatedDate = @"lastUpdatedDate",
	.like_count = @"like_count",
	.liked = @"liked",
	.likedDate = @"likedDate",
	.morselID = @"morselID",
	.morselPhotoURL = @"morselPhotoURL",
	.primary_item_id = @"primary_item_id",
	.publishedDate = @"publishedDate",
	.rank = @"rank",
	.sort_order = @"sort_order",
	.summary = @"summary",
	.tagged = @"tagged",
	.tagged_users_count = @"tagged_users_count",
	.title = @"title",
	.twitter_mrsl = @"twitter_mrsl",
	.url = @"url",
};

const struct MRSLMorselRelationships MRSLMorselRelationships = {
	.activitiesAsSubject = @"activitiesAsSubject",
	.collections = @"collections",
	.creator = @"creator",
	.items = @"items",
	.place = @"place",
};

const struct MRSLMorselFetchedProperties MRSLMorselFetchedProperties = {
};

@implementation MRSLMorselID
@end

@implementation _MRSLMorsel

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"MRSLMorsel" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"MRSLMorsel";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"MRSLMorsel" inManagedObjectContext:moc_];
}

- (MRSLMorselID*)objectID {
	return (MRSLMorselID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"draftValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"draft"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"feedItemFeaturedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"feedItemFeatured"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"feedItemIDValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"feedItemID"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"like_countValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"like_count"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"likedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"liked"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"morselIDValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"morselID"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"primary_item_idValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"primary_item_id"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"rankValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"rank"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"sort_orderValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"sort_order"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"taggedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"tagged"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"tagged_users_countValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"tagged_users_count"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic clipboard_mrsl;






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





@dynamic facebook_mrsl;






@dynamic feedItemFeatured;



- (BOOL)feedItemFeaturedValue {
	NSNumber *result = [self feedItemFeatured];
	return [result boolValue];
}

- (void)setFeedItemFeaturedValue:(BOOL)value_ {
	[self setFeedItemFeatured:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveFeedItemFeaturedValue {
	NSNumber *result = [self primitiveFeedItemFeatured];
	return [result boolValue];
}

- (void)setPrimitiveFeedItemFeaturedValue:(BOOL)value_ {
	[self setPrimitiveFeedItemFeatured:[NSNumber numberWithBool:value_]];
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





@dynamic liked;



- (BOOL)likedValue {
	NSNumber *result = [self liked];
	return [result boolValue];
}

- (void)setLikedValue:(BOOL)value_ {
	[self setLiked:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveLikedValue {
	NSNumber *result = [self primitiveLiked];
	return [result boolValue];
}

- (void)setPrimitiveLikedValue:(BOOL)value_ {
	[self setPrimitiveLiked:[NSNumber numberWithBool:value_]];
}





@dynamic likedDate;






@dynamic morselID;



- (int32_t)morselIDValue {
	NSNumber *result = [self morselID];
	return [result intValue];
}

- (void)setMorselIDValue:(int32_t)value_ {
	[self setMorselID:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveMorselIDValue {
	NSNumber *result = [self primitiveMorselID];
	return [result intValue];
}

- (void)setPrimitiveMorselIDValue:(int32_t)value_ {
	[self setPrimitiveMorselID:[NSNumber numberWithInt:value_]];
}





@dynamic morselPhotoURL;






@dynamic primary_item_id;



- (int32_t)primary_item_idValue {
	NSNumber *result = [self primary_item_id];
	return [result intValue];
}

- (void)setPrimary_item_idValue:(int32_t)value_ {
	[self setPrimary_item_id:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitivePrimary_item_idValue {
	NSNumber *result = [self primitivePrimary_item_id];
	return [result intValue];
}

- (void)setPrimitivePrimary_item_idValue:(int32_t)value_ {
	[self setPrimitivePrimary_item_id:[NSNumber numberWithInt:value_]];
}





@dynamic publishedDate;






@dynamic rank;



- (float)rankValue {
	NSNumber *result = [self rank];
	return [result floatValue];
}

- (void)setRankValue:(float)value_ {
	[self setRank:[NSNumber numberWithFloat:value_]];
}

- (float)primitiveRankValue {
	NSNumber *result = [self primitiveRank];
	return [result floatValue];
}

- (void)setPrimitiveRankValue:(float)value_ {
	[self setPrimitiveRank:[NSNumber numberWithFloat:value_]];
}





@dynamic sort_order;



- (int32_t)sort_orderValue {
	NSNumber *result = [self sort_order];
	return [result intValue];
}

- (void)setSort_orderValue:(int32_t)value_ {
	[self setSort_order:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveSort_orderValue {
	NSNumber *result = [self primitiveSort_order];
	return [result intValue];
}

- (void)setPrimitiveSort_orderValue:(int32_t)value_ {
	[self setPrimitiveSort_order:[NSNumber numberWithInt:value_]];
}





@dynamic summary;






@dynamic tagged;



- (BOOL)taggedValue {
	NSNumber *result = [self tagged];
	return [result boolValue];
}

- (void)setTaggedValue:(BOOL)value_ {
	[self setTagged:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveTaggedValue {
	NSNumber *result = [self primitiveTagged];
	return [result boolValue];
}

- (void)setPrimitiveTaggedValue:(BOOL)value_ {
	[self setPrimitiveTagged:[NSNumber numberWithBool:value_]];
}





@dynamic tagged_users_count;



- (int32_t)tagged_users_countValue {
	NSNumber *result = [self tagged_users_count];
	return [result intValue];
}

- (void)setTagged_users_countValue:(int32_t)value_ {
	[self setTagged_users_count:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveTagged_users_countValue {
	NSNumber *result = [self primitiveTagged_users_count];
	return [result intValue];
}

- (void)setPrimitiveTagged_users_countValue:(int32_t)value_ {
	[self setPrimitiveTagged_users_count:[NSNumber numberWithInt:value_]];
}





@dynamic title;






@dynamic twitter_mrsl;






@dynamic url;






@dynamic activitiesAsSubject;

	
- (NSMutableSet*)activitiesAsSubjectSet {
	[self willAccessValueForKey:@"activitiesAsSubject"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"activitiesAsSubject"];
  
	[self didAccessValueForKey:@"activitiesAsSubject"];
	return result;
}
	

@dynamic collections;

	
- (NSMutableSet*)collectionsSet {
	[self willAccessValueForKey:@"collections"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"collections"];
  
	[self didAccessValueForKey:@"collections"];
	return result;
}
	

@dynamic creator;

	

@dynamic items;

	
- (NSMutableSet*)itemsSet {
	[self willAccessValueForKey:@"items"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"items"];
  
	[self didAccessValueForKey:@"items"];
	return result;
}
	

@dynamic place;

	






@end
