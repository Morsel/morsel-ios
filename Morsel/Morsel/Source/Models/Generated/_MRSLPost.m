// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MRSLPost.m instead.

#import "_MRSLPost.h"

const struct MRSLPostAttributes MRSLPostAttributes = {
	.creationDate = @"creationDate",
	.draft = @"draft",
	.editing = @"editing",
	.postID = @"postID",
	.title = @"title",
};

const struct MRSLPostRelationships MRSLPostRelationships = {
	.author = @"author",
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
	if ([key isEqualToString:@"editingValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"editing"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"postIDValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"postID"];
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





@dynamic editing;



- (BOOL)editingValue {
	NSNumber *result = [self editing];
	return [result boolValue];
}

- (void)setEditingValue:(BOOL)value_ {
	[self setEditing:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveEditingValue {
	NSNumber *result = [self primitiveEditing];
	return [result boolValue];
}

- (void)setPrimitiveEditingValue:(BOOL)value_ {
	[self setPrimitiveEditing:[NSNumber numberWithBool:value_]];
}





@dynamic postID;



- (int16_t)postIDValue {
	NSNumber *result = [self postID];
	return [result shortValue];
}

- (void)setPostIDValue:(int16_t)value_ {
	[self setPostID:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitivePostIDValue {
	NSNumber *result = [self primitivePostID];
	return [result shortValue];
}

- (void)setPrimitivePostIDValue:(int16_t)value_ {
	[self setPrimitivePostID:[NSNumber numberWithShort:value_]];
}





@dynamic title;






@dynamic author;

	

@dynamic morsels;

	
- (NSMutableOrderedSet*)morselsSet {
	[self willAccessValueForKey:@"morsels"];
  
	NSMutableOrderedSet *result = (NSMutableOrderedSet*)[self mutableOrderedSetValueForKey:@"morsels"];
  
	[self didAccessValueForKey:@"morsels"];
	return result;
}
	






@end
