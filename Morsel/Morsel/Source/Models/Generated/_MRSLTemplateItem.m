// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MRSLTemplateItem.m instead.

#import "_MRSLTemplateItem.h"

const struct MRSLTemplateItemAttributes MRSLTemplateItemAttributes = {
	.placeholder_description = @"placeholder_description",
	.placeholder_id = @"placeholder_id",
	.placeholder_photo_large = @"placeholder_photo_large",
	.placeholder_photo_small = @"placeholder_photo_small",
	.placeholder_sort_order = @"placeholder_sort_order",
};

const struct MRSLTemplateItemRelationships MRSLTemplateItemRelationships = {
	.template = @"template",
};

const struct MRSLTemplateItemFetchedProperties MRSLTemplateItemFetchedProperties = {
};

@implementation MRSLTemplateItemID
@end

@implementation _MRSLTemplateItem

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"MRSLTemplateItem" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"MRSLTemplateItem";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"MRSLTemplateItem" inManagedObjectContext:moc_];
}

- (MRSLTemplateItemID*)objectID {
	return (MRSLTemplateItemID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"placeholder_idValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"placeholder_id"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"placeholder_sort_orderValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"placeholder_sort_order"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic placeholder_description;






@dynamic placeholder_id;



- (int16_t)placeholder_idValue {
	NSNumber *result = [self placeholder_id];
	return [result shortValue];
}

- (void)setPlaceholder_idValue:(int16_t)value_ {
	[self setPlaceholder_id:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitivePlaceholder_idValue {
	NSNumber *result = [self primitivePlaceholder_id];
	return [result shortValue];
}

- (void)setPrimitivePlaceholder_idValue:(int16_t)value_ {
	[self setPrimitivePlaceholder_id:[NSNumber numberWithShort:value_]];
}





@dynamic placeholder_photo_large;






@dynamic placeholder_photo_small;






@dynamic placeholder_sort_order;



- (int16_t)placeholder_sort_orderValue {
	NSNumber *result = [self placeholder_sort_order];
	return [result shortValue];
}

- (void)setPlaceholder_sort_orderValue:(int16_t)value_ {
	[self setPlaceholder_sort_order:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitivePlaceholder_sort_orderValue {
	NSNumber *result = [self primitivePlaceholder_sort_order];
	return [result shortValue];
}

- (void)setPrimitivePlaceholder_sort_orderValue:(int16_t)value_ {
	[self setPrimitivePlaceholder_sort_order:[NSNumber numberWithShort:value_]];
}





@dynamic template;

	






@end
