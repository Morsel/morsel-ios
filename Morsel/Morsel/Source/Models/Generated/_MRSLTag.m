// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MRSLTag.m instead.

#import "_MRSLTag.h"

const struct MRSLTagAttributes MRSLTagAttributes = {
	.name = @"name",
	.tagID = @"tagID",
};

const struct MRSLTagRelationships MRSLTagRelationships = {
	.morsels = @"morsels",
};

const struct MRSLTagFetchedProperties MRSLTagFetchedProperties = {
};

@implementation MRSLTagID
@end

@implementation _MRSLTag

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"MRSLTag" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"MRSLTag";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"MRSLTag" inManagedObjectContext:moc_];
}

- (MRSLTagID*)objectID {
	return (MRSLTagID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"tagIDValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"tagID"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic name;






@dynamic tagID;



- (int32_t)tagIDValue {
	NSNumber *result = [self tagID];
	return [result intValue];
}

- (void)setTagIDValue:(int32_t)value_ {
	[self setTagID:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveTagIDValue {
	NSNumber *result = [self primitiveTagID];
	return [result intValue];
}

- (void)setPrimitiveTagIDValue:(int32_t)value_ {
	[self setPrimitiveTagID:[NSNumber numberWithInt:value_]];
}





@dynamic morsels;

	
- (NSMutableSet*)morselsSet {
	[self willAccessValueForKey:@"morsels"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"morsels"];
  
	[self didAccessValueForKey:@"morsels"];
	return result;
}
	






@end
