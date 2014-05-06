// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MRSLTag.h instead.

#import <CoreData/CoreData.h>


extern const struct MRSLTagAttributes {
	__unsafe_unretained NSString *creationDate;
	__unsafe_unretained NSString *lastUpdatedDate;
	__unsafe_unretained NSString *tagID;
} MRSLTagAttributes;

extern const struct MRSLTagRelationships {
	__unsafe_unretained NSString *keyword;
	__unsafe_unretained NSString *user;
} MRSLTagRelationships;

extern const struct MRSLTagFetchedProperties {
} MRSLTagFetchedProperties;

@class MRSLKeyword;
@class MRSLUser;





@interface MRSLTagID : NSManagedObjectID {}
@end

@interface _MRSLTag : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MRSLTagID*)objectID;





@property (nonatomic, strong) NSDate* creationDate;



//- (BOOL)validateCreationDate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* lastUpdatedDate;



//- (BOOL)validateLastUpdatedDate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* tagID;



@property int32_t tagIDValue;
- (int32_t)tagIDValue;
- (void)setTagIDValue:(int32_t)value_;

//- (BOOL)validateTagID:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) MRSLKeyword *keyword;

//- (BOOL)validateKeyword:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) MRSLUser *user;

//- (BOOL)validateUser:(id*)value_ error:(NSError**)error_;





@end

@interface _MRSLTag (CoreDataGeneratedAccessors)

@end

@interface _MRSLTag (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveCreationDate;
- (void)setPrimitiveCreationDate:(NSDate*)value;




- (NSDate*)primitiveLastUpdatedDate;
- (void)setPrimitiveLastUpdatedDate:(NSDate*)value;




- (NSNumber*)primitiveTagID;
- (void)setPrimitiveTagID:(NSNumber*)value;

- (int32_t)primitiveTagIDValue;
- (void)setPrimitiveTagIDValue:(int32_t)value_;





- (MRSLKeyword*)primitiveKeyword;
- (void)setPrimitiveKeyword:(MRSLKeyword*)value;



- (MRSLUser*)primitiveUser;
- (void)setPrimitiveUser:(MRSLUser*)value;


@end
