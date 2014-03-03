// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MRSLSortOrder.h instead.

#import <CoreData/CoreData.h>


extern const struct MRSLSortOrderAttributes {
	__unsafe_unretained NSString *sortForPostID;
	__unsafe_unretained NSString *sortOrder;
} MRSLSortOrderAttributes;

extern const struct MRSLSortOrderRelationships {
	__unsafe_unretained NSString *morsel;
} MRSLSortOrderRelationships;

extern const struct MRSLSortOrderFetchedProperties {
} MRSLSortOrderFetchedProperties;

@class MRSLMorsel;




@interface MRSLSortOrderID : NSManagedObjectID {}
@end

@interface _MRSLSortOrder : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString *)entityName;
+ (NSEntityDescription *)entityInManagedObjectContext:(NSManagedObjectContext *)moc_;
- (MRSLSortOrderID *)objectID;





@property (strong, nonatomic) NSNumber *sortForPostID;



@property int16_t sortForPostIDValue;
- (int16_t)sortForPostIDValue;
- (void)setSortForPostIDValue:(int16_t)value_;

//- (BOOL)validateSortForPostID:(id *)value_ error:(NSError **)error_;





@property (strong, nonatomic) NSNumber *sortOrder;



@property int16_t sortOrderValue;
- (int16_t)sortOrderValue;
- (void)setSortOrderValue:(int16_t)value_;

//- (BOOL)validateSortOrder:(id *)value_ error:(NSError **)error_;





@property (strong, nonatomic) MRSLMorsel *morsel;

//- (BOOL)validateMorsel:(id *)value_ error:(NSError **)error_;





@end

@interface _MRSLSortOrder (CoreDataGeneratedAccessors)

@end

@interface _MRSLSortOrder (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber *)primitiveSortForPostID;
- (void)setPrimitiveSortForPostID:(NSNumber *)value;

- (int16_t)primitiveSortForPostIDValue;
- (void)setPrimitiveSortForPostIDValue:(int16_t)value_;




- (NSNumber *)primitiveSortOrder;
- (void)setPrimitiveSortOrder:(NSNumber *)value;

- (int16_t)primitiveSortOrderValue;
- (void)setPrimitiveSortOrderValue:(int16_t)value_;





- (MRSLMorsel *)primitiveMorsel;
- (void)setPrimitiveMorsel:(MRSLMorsel *)value;


@end
