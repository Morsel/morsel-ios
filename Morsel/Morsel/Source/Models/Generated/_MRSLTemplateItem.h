// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MRSLTemplateItem.h instead.

#import <CoreData/CoreData.h>


extern const struct MRSLTemplateItemAttributes {
	__unsafe_unretained NSString *placeholder_description;
	__unsafe_unretained NSString *placeholder_photo_large;
	__unsafe_unretained NSString *placeholder_photo_small;
	__unsafe_unretained NSString *placeholder_sort_order;
	__unsafe_unretained NSString *template_order;
} MRSLTemplateItemAttributes;

extern const struct MRSLTemplateItemRelationships {
	__unsafe_unretained NSString *template;
} MRSLTemplateItemRelationships;

extern const struct MRSLTemplateItemFetchedProperties {
} MRSLTemplateItemFetchedProperties;

@class MRSLTemplate;







@interface MRSLTemplateItemID : NSManagedObjectID {}
@end

@interface _MRSLTemplateItem : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MRSLTemplateItemID*)objectID;





@property (nonatomic, strong) NSString* placeholder_description;



//- (BOOL)validatePlaceholder_description:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* placeholder_photo_large;



//- (BOOL)validatePlaceholder_photo_large:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* placeholder_photo_small;



//- (BOOL)validatePlaceholder_photo_small:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* placeholder_sort_order;



@property int16_t placeholder_sort_orderValue;
- (int16_t)placeholder_sort_orderValue;
- (void)setPlaceholder_sort_orderValue:(int16_t)value_;

//- (BOOL)validatePlaceholder_sort_order:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* template_order;



@property int16_t template_orderValue;
- (int16_t)template_orderValue;
- (void)setTemplate_orderValue:(int16_t)value_;

//- (BOOL)validateTemplate_order:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) MRSLTemplate *template;

//- (BOOL)validateTemplate:(id*)value_ error:(NSError**)error_;





@end

@interface _MRSLTemplateItem (CoreDataGeneratedAccessors)

@end

@interface _MRSLTemplateItem (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitivePlaceholder_description;
- (void)setPrimitivePlaceholder_description:(NSString*)value;




- (NSString*)primitivePlaceholder_photo_large;
- (void)setPrimitivePlaceholder_photo_large:(NSString*)value;




- (NSString*)primitivePlaceholder_photo_small;
- (void)setPrimitivePlaceholder_photo_small:(NSString*)value;




- (NSNumber*)primitivePlaceholder_sort_order;
- (void)setPrimitivePlaceholder_sort_order:(NSNumber*)value;

- (int16_t)primitivePlaceholder_sort_orderValue;
- (void)setPrimitivePlaceholder_sort_orderValue:(int16_t)value_;




- (NSNumber*)primitiveTemplate_order;
- (void)setPrimitiveTemplate_order:(NSNumber*)value;

- (int16_t)primitiveTemplate_orderValue;
- (void)setPrimitiveTemplate_orderValue:(int16_t)value_;





- (MRSLTemplate*)primitiveTemplate;
- (void)setPrimitiveTemplate:(MRSLTemplate*)value;


@end
