// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MRSLSortOrder.m instead.

#import "_MRSLSortOrder.h"

const struct MRSLSortOrderAttributes MRSLSortOrderAttributes = {
	.sortForPostID = @"sortForPostID",
	.sortOrder = @"sortOrder",
};

const struct MRSLSortOrderRelationships MRSLSortOrderRelationships = {
	.morsel = @"morsel",
};

const struct MRSLSortOrderFetchedProperties MRSLSortOrderFetchedProperties = {
};

@implementation MRSLSortOrderID
@end

@implementation _MRSLSortOrder

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"MRSLSortOrder" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"MRSLSortOrder";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"MRSLSortOrder" inManagedObjectContext:moc_];
}

- (MRSLSortOrderID*)objectID {
	return (MRSLSortOrderID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"sortForPostIDValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"sortForPostID"];
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




@dynamic sortForPostID;



- (int16_t)sortForPostIDValue {
	NSNumber *result = [self sortForPostID];
	return [result shortValue];
}

- (void)setSortForPostIDValue:(int16_t)value_ {
	[self setSortForPostID:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveSortForPostIDValue {
	NSNumber *result = [self primitiveSortForPostID];
	return [result shortValue];
}

- (void)setPrimitiveSortForPostIDValue:(int16_t)value_ {
	[self setPrimitiveSortForPostID:[NSNumber numberWithShort:value_]];
}





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





@dynamic morsel;

	






@end
