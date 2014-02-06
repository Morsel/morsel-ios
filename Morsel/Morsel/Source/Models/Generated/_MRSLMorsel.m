// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MRSLMorsel.m instead.

#import "_MRSLMorsel.h"

const struct MRSLMorselAttributes MRSLMorselAttributes = {
	.creationDate = @"creationDate",
	.creator_id = @"creator_id",
	.draft = @"draft",
	.liked = @"liked",
	.morselDescription = @"morselDescription",
	.morselID = @"morselID",
	.morselPhoto = @"morselPhoto",
	.morselPhotoURL = @"morselPhotoURL",
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
	if ([key isEqualToString:@"draftValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"draft"];
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






@dynamic morselPhotoURL;






@dynamic comments;

	
- (NSMutableOrderedSet*)commentsSet {
	[self willAccessValueForKey:@"comments"];
  
	NSMutableOrderedSet *result = (NSMutableOrderedSet*)[self mutableOrderedSetValueForKey:@"comments"];
  
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
