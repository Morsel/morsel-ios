// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MRSLRemoteDevice.m instead.

#import "_MRSLRemoteDevice.h"

const struct MRSLRemoteDeviceAttributes MRSLRemoteDeviceAttributes = {
	.creationDate = @"creationDate",
	.deviceID = @"deviceID",
	.model = @"model",
	.name = @"name",
	.notify_item_comment = @"notify_item_comment",
	.notify_morsel_like = @"notify_morsel_like",
	.notify_morsel_morsel_user_tag = @"notify_morsel_morsel_user_tag",
	.notify_tagged_morsel_item_comment = @"notify_tagged_morsel_item_comment",
	.notify_user_follow = @"notify_user_follow",
	.token = @"token",
	.user_id = @"user_id",
};

const struct MRSLRemoteDeviceRelationships MRSLRemoteDeviceRelationships = {
};

const struct MRSLRemoteDeviceFetchedProperties MRSLRemoteDeviceFetchedProperties = {
};

@implementation MRSLRemoteDeviceID
@end

@implementation _MRSLRemoteDevice

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"MRSLRemoteDevice" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"MRSLRemoteDevice";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"MRSLRemoteDevice" inManagedObjectContext:moc_];
}

- (MRSLRemoteDeviceID*)objectID {
	return (MRSLRemoteDeviceID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"deviceIDValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"deviceID"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"notify_item_commentValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"notify_item_comment"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"notify_morsel_likeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"notify_morsel_like"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"notify_morsel_morsel_user_tagValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"notify_morsel_morsel_user_tag"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"notify_tagged_morsel_item_commentValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"notify_tagged_morsel_item_comment"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"notify_user_followValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"notify_user_follow"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"user_idValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"user_id"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic creationDate;






@dynamic deviceID;



- (int32_t)deviceIDValue {
	NSNumber *result = [self deviceID];
	return [result intValue];
}

- (void)setDeviceIDValue:(int32_t)value_ {
	[self setDeviceID:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveDeviceIDValue {
	NSNumber *result = [self primitiveDeviceID];
	return [result intValue];
}

- (void)setPrimitiveDeviceIDValue:(int32_t)value_ {
	[self setPrimitiveDeviceID:[NSNumber numberWithInt:value_]];
}





@dynamic model;






@dynamic name;






@dynamic notify_item_comment;



- (BOOL)notify_item_commentValue {
	NSNumber *result = [self notify_item_comment];
	return [result boolValue];
}

- (void)setNotify_item_commentValue:(BOOL)value_ {
	[self setNotify_item_comment:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveNotify_item_commentValue {
	NSNumber *result = [self primitiveNotify_item_comment];
	return [result boolValue];
}

- (void)setPrimitiveNotify_item_commentValue:(BOOL)value_ {
	[self setPrimitiveNotify_item_comment:[NSNumber numberWithBool:value_]];
}





@dynamic notify_morsel_like;



- (BOOL)notify_morsel_likeValue {
	NSNumber *result = [self notify_morsel_like];
	return [result boolValue];
}

- (void)setNotify_morsel_likeValue:(BOOL)value_ {
	[self setNotify_morsel_like:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveNotify_morsel_likeValue {
	NSNumber *result = [self primitiveNotify_morsel_like];
	return [result boolValue];
}

- (void)setPrimitiveNotify_morsel_likeValue:(BOOL)value_ {
	[self setPrimitiveNotify_morsel_like:[NSNumber numberWithBool:value_]];
}





@dynamic notify_morsel_morsel_user_tag;



- (BOOL)notify_morsel_morsel_user_tagValue {
	NSNumber *result = [self notify_morsel_morsel_user_tag];
	return [result boolValue];
}

- (void)setNotify_morsel_morsel_user_tagValue:(BOOL)value_ {
	[self setNotify_morsel_morsel_user_tag:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveNotify_morsel_morsel_user_tagValue {
	NSNumber *result = [self primitiveNotify_morsel_morsel_user_tag];
	return [result boolValue];
}

- (void)setPrimitiveNotify_morsel_morsel_user_tagValue:(BOOL)value_ {
	[self setPrimitiveNotify_morsel_morsel_user_tag:[NSNumber numberWithBool:value_]];
}





@dynamic notify_tagged_morsel_item_comment;



- (BOOL)notify_tagged_morsel_item_commentValue {
	NSNumber *result = [self notify_tagged_morsel_item_comment];
	return [result boolValue];
}

- (void)setNotify_tagged_morsel_item_commentValue:(BOOL)value_ {
	[self setNotify_tagged_morsel_item_comment:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveNotify_tagged_morsel_item_commentValue {
	NSNumber *result = [self primitiveNotify_tagged_morsel_item_comment];
	return [result boolValue];
}

- (void)setPrimitiveNotify_tagged_morsel_item_commentValue:(BOOL)value_ {
	[self setPrimitiveNotify_tagged_morsel_item_comment:[NSNumber numberWithBool:value_]];
}





@dynamic notify_user_follow;



- (BOOL)notify_user_followValue {
	NSNumber *result = [self notify_user_follow];
	return [result boolValue];
}

- (void)setNotify_user_followValue:(BOOL)value_ {
	[self setNotify_user_follow:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveNotify_user_followValue {
	NSNumber *result = [self primitiveNotify_user_follow];
	return [result boolValue];
}

- (void)setPrimitiveNotify_user_followValue:(BOOL)value_ {
	[self setPrimitiveNotify_user_follow:[NSNumber numberWithBool:value_]];
}





@dynamic token;






@dynamic user_id;



- (int32_t)user_idValue {
	NSNumber *result = [self user_id];
	return [result intValue];
}

- (void)setUser_idValue:(int32_t)value_ {
	[self setUser_id:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveUser_idValue {
	NSNumber *result = [self primitiveUser_id];
	return [result intValue];
}

- (void)setPrimitiveUser_idValue:(int32_t)value_ {
	[self setPrimitiveUser_id:[NSNumber numberWithInt:value_]];
}










@end
