// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MRSLPresignedUpload.m instead.

#import "_MRSLPresignedUpload.h"

const struct MRSLPresignedUploadAttributes MRSLPresignedUploadAttributes = {
	.acl = @"acl",
	.awsAccessKeyId = @"awsAccessKeyId",
	.key = @"key",
	.policy = @"policy",
	.signature = @"signature",
	.successActionStatus = @"successActionStatus",
	.url = @"url",
};

const struct MRSLPresignedUploadRelationships MRSLPresignedUploadRelationships = {
	.item = @"item",
};

const struct MRSLPresignedUploadFetchedProperties MRSLPresignedUploadFetchedProperties = {
};

@implementation MRSLPresignedUploadID
@end

@implementation _MRSLPresignedUpload

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"MRSLPresignedUpload" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"MRSLPresignedUpload";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"MRSLPresignedUpload" inManagedObjectContext:moc_];
}

- (MRSLPresignedUploadID*)objectID {
	return (MRSLPresignedUploadID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic acl;






@dynamic awsAccessKeyId;






@dynamic key;






@dynamic policy;






@dynamic signature;






@dynamic successActionStatus;






@dynamic url;






@dynamic item;

	






@end
