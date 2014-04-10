// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MRSLMorsel.m instead.

#import "_MRSLMorsel.h"

const struct MRSLMorselAttributes MRSLMorselAttributes = {
	.creationDate = @"creationDate",
	.draft = @"draft",
	.feedItemID = @"feedItemID",
	.lastUpdatedDate = @"lastUpdatedDate",
	.morselID = @"morselID",
	.morselPhotoURL = @"morselPhotoURL",
	.primary_item_id = @"primary_item_id",
	.publishedDate = @"publishedDate",
	.title = @"title",
	.total_comment_count = @"total_comment_count",
	.total_like_count = @"total_like_count",
	.url = @"url",
};

const struct MRSLMorselRelationships MRSLMorselRelationships = {
	.creator = @"creator",
	.items = @"items",
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
	if ([key isEqualToString:@"feedItemIDValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"feedItemID"];
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





@dynamic url;






@dynamic creator;

	

@dynamic items;

	
- (NSMutableSet*)itemsSet {
	[self willAccessValueForKey:@"items"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"items"];
  
	[self didAccessValueForKey:@"items"];
	return result;
}
	






@end
