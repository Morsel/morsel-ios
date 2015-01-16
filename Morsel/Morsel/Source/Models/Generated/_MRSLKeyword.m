// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MRSLKeyword.m instead.

#import "_MRSLKeyword.h"

const struct MRSLKeywordAttributes MRSLKeywordAttributes = {
	.keywordID = @"keywordID",
	.name = @"name",
	.tags_count = @"tags_count",
	.type = @"type",
};

const struct MRSLKeywordRelationships MRSLKeywordRelationships = {
	.tag = @"tag",
};

const struct MRSLKeywordFetchedProperties MRSLKeywordFetchedProperties = {
};

@implementation MRSLKeywordID
@end

@implementation _MRSLKeyword

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"MRSLKeyword" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"MRSLKeyword";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"MRSLKeyword" inManagedObjectContext:moc_];
}

- (MRSLKeywordID*)objectID {
	return (MRSLKeywordID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"keywordIDValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"keywordID"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"tags_countValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"tags_count"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic keywordID;



- (int32_t)keywordIDValue {
	NSNumber *result = [self keywordID];
	return [result intValue];
}

- (void)setKeywordIDValue:(int32_t)value_ {
	[self setKeywordID:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveKeywordIDValue {
	NSNumber *result = [self primitiveKeywordID];
	return [result intValue];
}

- (void)setPrimitiveKeywordIDValue:(int32_t)value_ {
	[self setPrimitiveKeywordID:[NSNumber numberWithInt:value_]];
}





@dynamic name;






@dynamic tags_count;



- (int32_t)tags_countValue {
	NSNumber *result = [self tags_count];
	return [result intValue];
}

- (void)setTags_countValue:(int32_t)value_ {
	[self setTags_count:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveTags_countValue {
	NSNumber *result = [self primitiveTags_count];
	return [result intValue];
}

- (void)setPrimitiveTags_countValue:(int32_t)value_ {
	[self setPrimitiveTags_count:[NSNumber numberWithInt:value_]];
}





@dynamic type;






@dynamic tag;

	






@end
