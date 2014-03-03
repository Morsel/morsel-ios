// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MRSLMorsel.m instead.

#import "_MRSLMorsel.h"

const struct MRSLMorselAttributes MRSLMorselAttributes = {
	.creationDate = @"creationDate",
	.creator_id = @"creator_id",
	.didFailUpload = @"didFailUpload",
	.isUploading = @"isUploading",
	.lastUpdatedDate = @"lastUpdatedDate",
	.liked = @"liked",
	.localUUID = @"localUUID",
	.morselDescription = @"morselDescription",
	.morselID = @"morselID",
	.morselPhoto = @"morselPhoto",
	.morselPhotoCropped = @"morselPhotoCropped",
	.morselPhotoThumb = @"morselPhotoThumb",
	.morselPhotoURL = @"morselPhotoURL",
	.sort_order = @"sort_order",
	.url = @"url",
};

const struct MRSLMorselRelationships MRSLMorselRelationships = {
	.comments = @"comments",
	.post = @"post",
	.tags = @"tags",
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
	if ([key isEqualToString:@"sort_orderValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"sort_order"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic creationDate;






@dynamic creator_id;



- (int16_t)creator_idValue {
	NSNumber *result = [self creator_id];
	return [result shortValue];
}

- (void)setCreator_idValue:(int16_t)value_ {
	[self setCreator_id:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveCreator_idValue {
	NSNumber *result = [self primitiveCreator_id];
	return [result shortValue];
}

- (void)setPrimitiveCreator_idValue:(int16_t)value_ {
	[self setPrimitiveCreator_id:[NSNumber numberWithShort:value_]];
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





@dynamic lastUpdatedDate;






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





@dynamic localUUID;






@dynamic morselDescription;






@dynamic morselID;



- (int16_t)morselIDValue {
	NSNumber *result = [self morselID];
	return [result shortValue];
}

- (void)setMorselIDValue:(int16_t)value_ {
	[self setMorselID:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveMorselIDValue {
	NSNumber *result = [self primitiveMorselID];
	return [result shortValue];
}

- (void)setPrimitiveMorselIDValue:(int16_t)value_ {
	[self setPrimitiveMorselID:[NSNumber numberWithShort:value_]];
}





@dynamic morselPhoto;






@dynamic morselPhotoCropped;






@dynamic morselPhotoThumb;






@dynamic morselPhotoURL;






@dynamic sort_order;



- (int16_t)sort_orderValue {
	NSNumber *result = [self sort_order];
	return [result shortValue];
}

- (void)setSort_orderValue:(int16_t)value_ {
	[self setSort_order:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveSort_orderValue {
	NSNumber *result = [self primitiveSort_order];
	return [result shortValue];
}

- (void)setPrimitiveSort_orderValue:(int16_t)value_ {
	[self setPrimitiveSort_order:[NSNumber numberWithShort:value_]];
}





@dynamic url;






@dynamic comments;

	
- (NSMutableSet*)commentsSet {
	[self willAccessValueForKey:@"comments"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"comments"];
  
	[self didAccessValueForKey:@"comments"];
	return result;
}
	

@dynamic post;

	

@dynamic tags;

	
- (NSMutableSet*)tagsSet {
	[self willAccessValueForKey:@"tags"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"tags"];
  
	[self didAccessValueForKey:@"tags"];
	return result;
}
	






@end
