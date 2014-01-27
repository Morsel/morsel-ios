// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MRSLMorsel.m instead.

#import "_MRSLMorsel.h"

const struct MRSLMorselAttributes MRSLMorselAttributes = {
	.creationDate = @"creationDate",
	.isDraft = @"isDraft",
	.liked = @"liked",
	.morselDescription = @"morselDescription",
	.morselID = @"morselID",
	.morselPicture = @"morselPicture",
	.morselPictureCropped = @"morselPictureCropped",
	.morselPictureURL = @"morselPictureURL",
	.morselThumb = @"morselThumb",
	.morselThumbURL = @"morselThumbURL",
	.sortOrder = @"sortOrder",
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
	
	if ([key isEqualToString:@"isDraftValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isDraft"];
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
	if ([key isEqualToString:@"sortOrderValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"sortOrder"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic creationDate;






@dynamic isDraft;



- (BOOL)isDraftValue {
	NSNumber *result = [self isDraft];
	return [result boolValue];
}

- (void)setIsDraftValue:(BOOL)value_ {
	[self setIsDraft:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsDraftValue {
	NSNumber *result = [self primitiveIsDraft];
	return [result boolValue];
}

- (void)setPrimitiveIsDraftValue:(BOOL)value_ {
	[self setPrimitiveIsDraft:[NSNumber numberWithBool:value_]];
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





@dynamic morselPicture;






@dynamic morselPictureCropped;






@dynamic morselPictureURL;






@dynamic morselThumb;






@dynamic morselThumbURL;






@dynamic sortOrder;



- (int16_t)sortOrderValue {
	NSNumber *result = [self sortOrder];
	return [result shortValue];
}

- (void)setSortOrderValue:(int16_t)value_ {
	[self setSortOrder:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveSortOrderValue {
	NSNumber *result = [self primitiveSortOrder];
	return [result shortValue];
}

- (void)setPrimitiveSortOrderValue:(int16_t)value_ {
	[self setPrimitiveSortOrder:[NSNumber numberWithShort:value_]];
}





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
