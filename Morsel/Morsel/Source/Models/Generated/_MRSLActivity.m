// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MRSLActivity.m instead.

#import "_MRSLActivity.h"

const struct MRSLActivityAttributes MRSLActivityAttributes = {
	.actionType = @"actionType",
	.activityID = @"activityID",
	.creationDate = @"creationDate",
	.subjectID = @"subjectID",
	.subjectType = @"subjectType",
};

const struct MRSLActivityRelationships MRSLActivityRelationships = {
	.creator = @"creator",
	.itemSubject = @"itemSubject",
	.notification = @"notification",
	.userSubject = @"userSubject",
};

const struct MRSLActivityFetchedProperties MRSLActivityFetchedProperties = {
};

@implementation MRSLActivityID
@end

@implementation _MRSLActivity

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"MRSLActivity" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"MRSLActivity";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"MRSLActivity" inManagedObjectContext:moc_];
}

- (MRSLActivityID*)objectID {
	return (MRSLActivityID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"activityIDValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"activityID"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"subjectIDValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"subjectID"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic actionType;






@dynamic activityID;



- (int32_t)activityIDValue {
	NSNumber *result = [self activityID];
	return [result intValue];
}

- (void)setActivityIDValue:(int32_t)value_ {
	[self setActivityID:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveActivityIDValue {
	NSNumber *result = [self primitiveActivityID];
	return [result intValue];
}

- (void)setPrimitiveActivityIDValue:(int32_t)value_ {
	[self setPrimitiveActivityID:[NSNumber numberWithInt:value_]];
}





@dynamic creationDate;






@dynamic subjectID;



- (int32_t)subjectIDValue {
	NSNumber *result = [self subjectID];
	return [result intValue];
}

- (void)setSubjectIDValue:(int32_t)value_ {
	[self setSubjectID:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveSubjectIDValue {
	NSNumber *result = [self primitiveSubjectID];
	return [result intValue];
}

- (void)setPrimitiveSubjectIDValue:(int32_t)value_ {
	[self setPrimitiveSubjectID:[NSNumber numberWithInt:value_]];
}





@dynamic subjectType;






@dynamic creator;

	

@dynamic itemSubject;

	

@dynamic notification;

	

@dynamic userSubject;

	






@end
