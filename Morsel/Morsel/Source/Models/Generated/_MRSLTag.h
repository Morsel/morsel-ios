// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MRSLTag.h instead.

#import <CoreData/CoreData.h>


extern const struct MRSLTagAttributes {
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *tagID;
} MRSLTagAttributes;

extern const struct MRSLTagRelationships {
	__unsafe_unretained NSString *items;
} MRSLTagRelationships;

extern const struct MRSLTagFetchedProperties {
} MRSLTagFetchedProperties;

@class MRSLItem;




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



@property int32_t tagIDValue;
- (int32_t)tagIDValue;
- (void)setTagIDValue:(int32_t)value_;

//- (BOOL)validateTagID:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *items;

- (NSMutableSet*)itemsSet;





@end

@interface _MRSLTag (CoreDataGeneratedAccessors)

- (void)addItems:(NSSet*)value_;
- (void)removeItems:(NSSet*)value_;
- (void)addItemsObject:(MRSLItem*)value_;
- (void)removeItemsObject:(MRSLItem*)value_;

@end

@interface _MRSLTag (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSNumber*)primitiveTagID;
- (void)setPrimitiveTagID:(NSNumber*)value;

- (int32_t)primitiveTagIDValue;
- (void)setPrimitiveTagIDValue:(int32_t)value_;





- (NSMutableSet*)primitiveItems;
- (void)setPrimitiveItems:(NSMutableSet*)value;


@end
