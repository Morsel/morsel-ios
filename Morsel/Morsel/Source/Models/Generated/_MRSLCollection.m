// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MRSLCollection.m instead.

#import "_MRSLCollection.h"

const struct MRSLCollectionAttributes MRSLCollectionAttributes = {
	.collectionDescription = @"collectionDescription",
	.collectionID = @"collectionID",
	.creationDate = @"creationDate",
	.title = @"title",
	.updatedDate = @"updatedDate",
	.url = @"url",
};

const struct MRSLCollectionRelationships MRSLCollectionRelationships = {
	.creator = @"creator",
	.morsels = @"morsels",
	.place = @"place",
};

const struct MRSLCollectionFetchedProperties MRSLCollectionFetchedProperties = {
};

@implementation MRSLCollectionID
@end

@implementation _MRSLCollection

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"MRSLCollection" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"MRSLCollection";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"MRSLCollection" inManagedObjectContext:moc_];
}

- (MRSLCollectionID*)objectID {
	return (MRSLCollectionID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"collectionIDValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"collectionID"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic collectionDescription;






@dynamic collectionID;



- (int32_t)collectionIDValue {
	NSNumber *result = [self collectionID];
	return [result intValue];
}

- (void)setCollectionIDValue:(int32_t)value_ {
	[self setCollectionID:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveCollectionIDValue {
	NSNumber *result = [self primitiveCollectionID];
	return [result intValue];
}

- (void)setPrimitiveCollectionIDValue:(int32_t)value_ {
	[self setPrimitiveCollectionID:[NSNumber numberWithInt:value_]];
}





@dynamic creationDate;






@dynamic title;






@dynamic updatedDate;






@dynamic url;






@dynamic creator;

	

@dynamic morsels;

	
- (NSMutableSet*)morselsSet {
	[self willAccessValueForKey:@"morsels"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"morsels"];
  
	[self didAccessValueForKey:@"morsels"];
	return result;
}
	

@dynamic place;

	






@end
