// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MRSLItem.m instead.

#import "_MRSLItem.h"

const struct MRSLItemAttributes MRSLItemAttributes = {
	.comment_count = @"comment_count",
	.creationDate = @"creationDate",
	.creator_id = @"creator_id",
	.didFailUpload = @"didFailUpload",
	.isUploading = @"isUploading",
	.itemDescription = @"itemDescription",
	.itemID = @"itemID",
	.itemPhotoCropped = @"itemPhotoCropped",
	.itemPhotoFull = @"itemPhotoFull",
	.itemPhotoThumb = @"itemPhotoThumb",
	.itemPhotoURL = @"itemPhotoURL",
	.lastUpdatedDate = @"lastUpdatedDate",
	.like_count = @"like_count",
	.liked = @"liked",
	.likedDate = @"likedDate",
	.localUUID = @"localUUID",
	.morsel_id = @"morsel_id",
	.photo_processing = @"photo_processing",
	.sort_order = @"sort_order",
	.url = @"url",
};

const struct MRSLItemRelationships MRSLItemRelationships = {
	.activities = @"activities",
	.comments = @"comments",
	.morsel = @"morsel",
};

const struct MRSLItemFetchedProperties MRSLItemFetchedProperties = {
};

@implementation MRSLItemID
@end

@implementation _MRSLItem

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"MRSLItem" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"MRSLItem";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"MRSLItem" inManagedObjectContext:moc_];
}

- (MRSLItemID*)objectID {
	return (MRSLItemID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"comment_countValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"comment_count"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"creator_idValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"creator_id"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"didFailUploadValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"didFailUpload"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"isUploadingValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isUploading"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"itemIDValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"itemID"];
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
	if ([key isEqualToString:@"morsel_idValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"morsel_id"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"photo_processingValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"photo_processing"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"sort_orderValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"sort_order"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic comment_count;



- (int32_t)comment_countValue {
	NSNumber *result = [self comment_count];
	return [result intValue];
}

- (void)setComment_countValue:(int32_t)value_ {
	[self setComment_count:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveComment_countValue {
	NSNumber *result = [self primitiveComment_count];
	return [result intValue];
}

- (void)setPrimitiveComment_countValue:(int32_t)value_ {
	[self setPrimitiveComment_count:[NSNumber numberWithInt:value_]];
}





@dynamic creationDate;






@dynamic creator_id;



- (int32_t)creator_idValue {
	NSNumber *result = [self creator_id];
	return [result intValue];
}

- (void)setCreator_idValue:(int32_t)value_ {
	[self setCreator_id:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveCreator_idValue {
	NSNumber *result = [self primitiveCreator_id];
	return [result intValue];
}

- (void)setPrimitiveCreator_idValue:(int32_t)value_ {
	[self setPrimitiveCreator_id:[NSNumber numberWithInt:value_]];
}





@dynamic didFailUpload;



- (BOOL)didFailUploadValue {
	NSNumber *result = [self didFailUpload];
	return [result boolValue];
}

- (void)setDidFailUploadValue:(BOOL)value_ {
	[self setDidFailUpload:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveDidFailUploadValue {
	NSNumber *result = [self primitiveDidFailUpload];
	return [result boolValue];
}

- (void)setPrimitiveDidFailUploadValue:(BOOL)value_ {
	[self setPrimitiveDidFailUpload:[NSNumber numberWithBool:value_]];
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





@dynamic itemDescription;






@dynamic itemID;



- (int32_t)itemIDValue {
	NSNumber *result = [self itemID];
	return [result intValue];
}

- (void)setItemIDValue:(int32_t)value_ {
	[self setItemID:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveItemIDValue {
	NSNumber *result = [self primitiveItemID];
	return [result intValue];
}

- (void)setPrimitiveItemIDValue:(int32_t)value_ {
	[self setPrimitiveItemID:[NSNumber numberWithInt:value_]];
}





@dynamic itemPhotoCropped;






@dynamic itemPhotoFull;






@dynamic itemPhotoThumb;






@dynamic itemPhotoURL;






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






@dynamic localUUID;






@dynamic morsel_id;



- (int32_t)morsel_idValue {
	NSNumber *result = [self morsel_id];
	return [result intValue];
}

- (void)setMorsel_idValue:(int32_t)value_ {
	[self setMorsel_id:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveMorsel_idValue {
	NSNumber *result = [self primitiveMorsel_id];
	return [result intValue];
}

- (void)setPrimitiveMorsel_idValue:(int32_t)value_ {
	[self setPrimitiveMorsel_id:[NSNumber numberWithInt:value_]];
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





@dynamic url;






@dynamic activities;

	
- (NSMutableSet*)activitiesSet {
	[self willAccessValueForKey:@"activities"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"activities"];
  
	[self didAccessValueForKey:@"activities"];
	return result;
}
	

@dynamic comments;

	
- (NSMutableSet*)commentsSet {
	[self willAccessValueForKey:@"comments"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"comments"];
  
	[self didAccessValueForKey:@"comments"];
	return result;
}
	

@dynamic morsel;

	






@end
