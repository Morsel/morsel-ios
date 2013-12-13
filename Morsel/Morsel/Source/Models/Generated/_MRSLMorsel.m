// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MRSLMorsel.m instead.

#import "_MRSLMorsel.h"

const struct MRSLMorselAttributes MRSLMorselAttributes = {
	.creationDate = @"creationDate",
	.morselDescription = @"morselDescription",
	.morselID = @"morselID",
	.morselPicture = @"morselPicture",
	.morselThumb = @"morselThumb",
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
	
	if ([key isEqualToString:@"morselIDValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"morselID"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic creationDate;






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






@dynamic morselThumb;






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
