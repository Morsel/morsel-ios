// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MRSLKeyword.h instead.

#import <CoreData/CoreData.h>


extern const struct MRSLKeywordAttributes {
	__unsafe_unretained NSString *keywordID;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *type;
} MRSLKeywordAttributes;

extern const struct MRSLKeywordRelationships {
	__unsafe_unretained NSString *tag;
} MRSLKeywordRelationships;

extern const struct MRSLKeywordFetchedProperties {
} MRSLKeywordFetchedProperties;

@class MRSLTag;





@interface MRSLKeywordID : NSManagedObjectID {}
@end

@interface _MRSLKeyword : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MRSLKeywordID*)objectID;





@property (nonatomic, strong) NSNumber* keywordID;



@property int32_t keywordIDValue;
- (int32_t)keywordIDValue;
- (void)setKeywordIDValue:(int32_t)value_;

//- (BOOL)validateKeywordID:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* type;



//- (BOOL)validateType:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) MRSLTag *tag;

//- (BOOL)validateTag:(id*)value_ error:(NSError**)error_;





@end

@interface _MRSLKeyword (CoreDataGeneratedAccessors)

@end

@interface _MRSLKeyword (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveKeywordID;
- (void)setPrimitiveKeywordID:(NSNumber*)value;

- (int32_t)primitiveKeywordIDValue;
- (void)setPrimitiveKeywordIDValue:(int32_t)value_;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSString*)primitiveType;
- (void)setPrimitiveType:(NSString*)value;





- (MRSLTag*)primitiveTag;
- (void)setPrimitiveTag:(MRSLTag*)value;


@end
