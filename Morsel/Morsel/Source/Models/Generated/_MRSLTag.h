// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MRSLTag.h instead.

#import <CoreData/CoreData.h>


extern const struct MRSLTagAttributes {
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *tagID;
} MRSLTagAttributes;

extern const struct MRSLTagRelationships {
	__unsafe_unretained NSString *morsels;
} MRSLTagRelationships;

extern const struct MRSLTagFetchedProperties {
} MRSLTagFetchedProperties;

@class MRSLMorsel;




@interface MRSLTagID : NSManagedObjectID {}
@end

@interface _MRSLTag : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MRSLTagID*)objectID;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* tagID;



@property int16_t tagIDValue;
- (int16_t)tagIDValue;
- (void)setTagIDValue:(int16_t)value_;

//- (BOOL)validateTagID:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *morsels;

- (NSMutableSet*)morselsSet;





@end

@interface _MRSLTag (CoreDataGeneratedAccessors)

- (void)addMorsels:(NSSet*)value_;
- (void)removeMorsels:(NSSet*)value_;
- (void)addMorselsObject:(MRSLMorsel*)value_;
- (void)removeMorselsObject:(MRSLMorsel*)value_;

@end

@interface _MRSLTag (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSNumber*)primitiveTagID;
- (void)setPrimitiveTagID:(NSNumber*)value;

- (int16_t)primitiveTagIDValue;
- (void)setPrimitiveTagIDValue:(int16_t)value_;





- (NSMutableSet*)primitiveMorsels;
- (void)setPrimitiveMorsels:(NSMutableSet*)value;


@end
