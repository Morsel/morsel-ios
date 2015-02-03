// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MRSLCollection.h instead.

#import <CoreData/CoreData.h>


extern const struct MRSLCollectionAttributes {
	__unsafe_unretained NSString *collectionDescription;
	__unsafe_unretained NSString *collectionID;
	__unsafe_unretained NSString *creationDate;
	__unsafe_unretained NSString *title;
	__unsafe_unretained NSString *updatedDate;
	__unsafe_unretained NSString *url;
} MRSLCollectionAttributes;

extern const struct MRSLCollectionRelationships {
	__unsafe_unretained NSString *creator;
	__unsafe_unretained NSString *morsels;
	__unsafe_unretained NSString *place;
} MRSLCollectionRelationships;

extern const struct MRSLCollectionFetchedProperties {
} MRSLCollectionFetchedProperties;

@class MRSLUser;
@class MRSLMorsel;
@class MRSLPlace;








@interface MRSLCollectionID : NSManagedObjectID {}
@end

@interface _MRSLCollection : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MRSLCollectionID*)objectID;





@property (nonatomic, strong) NSString* collectionDescription;



//- (BOOL)validateCollectionDescription:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* collectionID;



@property int32_t collectionIDValue;
- (int32_t)collectionIDValue;
- (void)setCollectionIDValue:(int32_t)value_;

//- (BOOL)validateCollectionID:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* creationDate;



//- (BOOL)validateCreationDate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* title;



//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* updatedDate;



//- (BOOL)validateUpdatedDate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* url;



//- (BOOL)validateUrl:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) MRSLUser *creator;

//- (BOOL)validateCreator:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSSet *morsels;

- (NSMutableSet*)morselsSet;




@property (nonatomic, strong) MRSLPlace *place;

//- (BOOL)validatePlace:(id*)value_ error:(NSError**)error_;





@end

@interface _MRSLCollection (CoreDataGeneratedAccessors)

- (void)addMorsels:(NSSet*)value_;
- (void)removeMorsels:(NSSet*)value_;
- (void)addMorselsObject:(MRSLMorsel*)value_;
- (void)removeMorselsObject:(MRSLMorsel*)value_;

@end

@interface _MRSLCollection (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveCollectionDescription;
- (void)setPrimitiveCollectionDescription:(NSString*)value;




- (NSNumber*)primitiveCollectionID;
- (void)setPrimitiveCollectionID:(NSNumber*)value;

- (int32_t)primitiveCollectionIDValue;
- (void)setPrimitiveCollectionIDValue:(int32_t)value_;




- (NSDate*)primitiveCreationDate;
- (void)setPrimitiveCreationDate:(NSDate*)value;




- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;




- (NSDate*)primitiveUpdatedDate;
- (void)setPrimitiveUpdatedDate:(NSDate*)value;




- (NSString*)primitiveUrl;
- (void)setPrimitiveUrl:(NSString*)value;





- (MRSLUser*)primitiveCreator;
- (void)setPrimitiveCreator:(MRSLUser*)value;



- (NSMutableSet*)primitiveMorsels;
- (void)setPrimitiveMorsels:(NSMutableSet*)value;



- (MRSLPlace*)primitivePlace;
- (void)setPrimitivePlace:(MRSLPlace*)value;


@end
