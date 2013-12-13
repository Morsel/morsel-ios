// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MRSLPost.m instead.

#import "_MRSLPost.h"

const struct MRSLPostAttributes MRSLPostAttributes = {
	.creationDate = @"creationDate",
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
	
	if ([key isEqualToString:@"postIDValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"postID"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic creationDate;






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
