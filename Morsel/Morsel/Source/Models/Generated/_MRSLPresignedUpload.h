// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MRSLPresignedUpload.h instead.

#import <CoreData/CoreData.h>


extern const struct MRSLPresignedUploadAttributes {
	__unsafe_unretained NSString *acl;
	__unsafe_unretained NSString *awsAccessKeyId;
	__unsafe_unretained NSString *key;
	__unsafe_unretained NSString *policy;
	__unsafe_unretained NSString *signature;
	__unsafe_unretained NSString *successActionStatus;
	__unsafe_unretained NSString *url;
} MRSLPresignedUploadAttributes;

extern const struct MRSLPresignedUploadRelationships {
	__unsafe_unretained NSString *item;
} MRSLPresignedUploadRelationships;

extern const struct MRSLPresignedUploadFetchedProperties {
} MRSLPresignedUploadFetchedProperties;

@class MRSLItem;









@interface MRSLPresignedUploadID : NSManagedObjectID {}
@end

@interface _MRSLPresignedUpload : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MRSLPresignedUploadID*)objectID;





@property (nonatomic, strong) NSString* acl;



//- (BOOL)validateAcl:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* awsAccessKeyId;



//- (BOOL)validateAwsAccessKeyId:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* key;



//- (BOOL)validateKey:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* policy;



//- (BOOL)validatePolicy:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* signature;



//- (BOOL)validateSignature:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* successActionStatus;



//- (BOOL)validateSuccessActionStatus:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* url;



//- (BOOL)validateUrl:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) MRSLItem *item;

//- (BOOL)validateItem:(id*)value_ error:(NSError**)error_;





@end

@interface _MRSLPresignedUpload (CoreDataGeneratedAccessors)

@end

@interface _MRSLPresignedUpload (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveAcl;
- (void)setPrimitiveAcl:(NSString*)value;




- (NSString*)primitiveAwsAccessKeyId;
- (void)setPrimitiveAwsAccessKeyId:(NSString*)value;




- (NSString*)primitiveKey;
- (void)setPrimitiveKey:(NSString*)value;




- (NSString*)primitivePolicy;
- (void)setPrimitivePolicy:(NSString*)value;




- (NSString*)primitiveSignature;
- (void)setPrimitiveSignature:(NSString*)value;




- (NSString*)primitiveSuccessActionStatus;
- (void)setPrimitiveSuccessActionStatus:(NSString*)value;




- (NSString*)primitiveUrl;
- (void)setPrimitiveUrl:(NSString*)value;





- (MRSLItem*)primitiveItem;
- (void)setPrimitiveItem:(MRSLItem*)value;


@end
