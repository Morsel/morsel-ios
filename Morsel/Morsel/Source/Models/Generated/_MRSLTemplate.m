// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MRSLTemplate.m instead.

#import "_MRSLTemplate.h"

const struct MRSLTemplateAttributes MRSLTemplateAttributes = {
	.icon = @"icon",
	.templateDescription = @"templateDescription",
	.templateID = @"templateID",
	.tip = @"tip",
	.title = @"title",
};

const struct MRSLTemplateRelationships MRSLTemplateRelationships = {
	.items = @"items",
};

const struct MRSLTemplateFetchedProperties MRSLTemplateFetchedProperties = {
};

@implementation MRSLTemplateID
@end

@implementation _MRSLTemplate

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"MRSLTemplate" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"MRSLTemplate";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"MRSLTemplate" inManagedObjectContext:moc_];
}

- (MRSLTemplateID*)objectID {
	return (MRSLTemplateID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"templateIDValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"templateID"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic icon;






@dynamic templateDescription;






@dynamic templateID;



- (int16_t)templateIDValue {
	NSNumber *result = [self templateID];
	return [result shortValue];
}

- (void)setTemplateIDValue:(int16_t)value_ {
	[self setTemplateID:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveTemplateIDValue {
	NSNumber *result = [self primitiveTemplateID];
	return [result shortValue];
}

- (void)setPrimitiveTemplateIDValue:(int16_t)value_ {
	[self setPrimitiveTemplateID:[NSNumber numberWithShort:value_]];
}





@dynamic tip;






@dynamic title;






@dynamic items;

	
- (NSMutableSet*)itemsSet {
	[self willAccessValueForKey:@"items"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"items"];
  
	[self didAccessValueForKey:@"items"];
	return result;
}
	






@end
