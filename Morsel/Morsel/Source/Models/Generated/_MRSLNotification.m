// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MRSLNotification.m instead.

#import "_MRSLNotification.h"

const struct MRSLNotificationAttributes MRSLNotificationAttributes = {
	.creationDate = @"creationDate",
	.message = @"message",
	.notificationID = @"notificationID",
	.payloadID = @"payloadID",
	.payloadType = @"payloadType",
};

const struct MRSLNotificationRelationships MRSLNotificationRelationships = {
	.activity = @"activity",
};

const struct MRSLNotificationFetchedProperties MRSLNotificationFetchedProperties = {
};

@implementation MRSLNotificationID
@end

@implementation _MRSLNotification

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"MRSLNotification" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"MRSLNotification";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"MRSLNotification" inManagedObjectContext:moc_];
}

- (MRSLNotificationID*)objectID {
	return (MRSLNotificationID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"notificationIDValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"notificationID"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"payloadIDValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"payloadID"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic creationDate;






@dynamic message;






@dynamic notificationID;



- (int32_t)notificationIDValue {
	NSNumber *result = [self notificationID];
	return [result intValue];
}

- (void)setNotificationIDValue:(int32_t)value_ {
	[self setNotificationID:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveNotificationIDValue {
	NSNumber *result = [self primitiveNotificationID];
	return [result intValue];
}

- (void)setPrimitiveNotificationIDValue:(int32_t)value_ {
	[self setPrimitiveNotificationID:[NSNumber numberWithInt:value_]];
}





@dynamic payloadID;



- (int32_t)payloadIDValue {
	NSNumber *result = [self payloadID];
	return [result intValue];
}

- (void)setPayloadIDValue:(int32_t)value_ {
	[self setPayloadID:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitivePayloadIDValue {
	NSNumber *result = [self primitivePayloadID];
	return [result intValue];
}

- (void)setPrimitivePayloadIDValue:(int32_t)value_ {
	[self setPrimitivePayloadID:[NSNumber numberWithInt:value_]];
}





@dynamic payloadType;






@dynamic activity;

	






@end
