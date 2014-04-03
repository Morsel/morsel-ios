// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MRSLComment.m instead.

#import "_MRSLComment.h"

const struct MRSLCommentAttributes MRSLCommentAttributes = {
	.commentDescription = @"commentDescription",
	.commentID = @"commentID",
	.creationDate = @"creationDate",
};

const struct MRSLCommentRelationships MRSLCommentRelationships = {
	.creator = @"creator",
	.morsel = @"morsel",
};

const struct MRSLCommentFetchedProperties MRSLCommentFetchedProperties = {
};

@implementation MRSLCommentID
@end

@implementation _MRSLComment

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"MRSLComment" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"MRSLComment";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"MRSLComment" inManagedObjectContext:moc_];
}

- (MRSLCommentID*)objectID {
	return (MRSLCommentID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"commentIDValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"commentID"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic commentDescription;






@dynamic commentID;



- (int32_t)commentIDValue {
	NSNumber *result = [self commentID];
	return [result intValue];
}

- (void)setCommentIDValue:(int32_t)value_ {
	[self setCommentID:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveCommentIDValue {
	NSNumber *result = [self primitiveCommentID];
	return [result intValue];
}

- (void)setPrimitiveCommentIDValue:(int32_t)value_ {
	[self setPrimitiveCommentID:[NSNumber numberWithInt:value_]];
}





@dynamic creationDate;






@dynamic creator;

	

@dynamic morsel;

	






@end
