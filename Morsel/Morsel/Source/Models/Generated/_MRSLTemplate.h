// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MRSLTemplate.h instead.

#import <CoreData/CoreData.h>


extern const struct MRSLTemplateAttributes {
	__unsafe_unretained NSString *icon;
	__unsafe_unretained NSString *templateDescription;
	__unsafe_unretained NSString *templateID;
	__unsafe_unretained NSString *tip;
	__unsafe_unretained NSString *title;
} MRSLTemplateAttributes;

extern const struct MRSLTemplateRelationships {
	__unsafe_unretained NSString *items;
} MRSLTemplateRelationships;

extern const struct MRSLTemplateFetchedProperties {
} MRSLTemplateFetchedProperties;

@class MRSLTemplateItem;







@interface MRSLTemplateID : NSManagedObjectID {}
@end

@interface _MRSLTemplate : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MRSLTemplateID*)objectID;





@property (nonatomic, strong) NSString* icon;



//- (BOOL)validateIcon:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* templateDescription;



//- (BOOL)validateTemplateDescription:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* templateID;



@property int16_t templateIDValue;
- (int16_t)templateIDValue;
- (void)setTemplateIDValue:(int16_t)value_;

//- (BOOL)validateTemplateID:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* tip;



//- (BOOL)validateTip:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* title;



//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *items;

- (NSMutableSet*)itemsSet;





@end

@interface _MRSLTemplate (CoreDataGeneratedAccessors)

- (void)addItems:(NSSet*)value_;
- (void)removeItems:(NSSet*)value_;
- (void)addItemsObject:(MRSLTemplateItem*)value_;
- (void)removeItemsObject:(MRSLTemplateItem*)value_;

@end

@interface _MRSLTemplate (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveIcon;
- (void)setPrimitiveIcon:(NSString*)value;




- (NSString*)primitiveTemplateDescription;
- (void)setPrimitiveTemplateDescription:(NSString*)value;




- (NSNumber*)primitiveTemplateID;
- (void)setPrimitiveTemplateID:(NSNumber*)value;

- (int16_t)primitiveTemplateIDValue;
- (void)setPrimitiveTemplateIDValue:(int16_t)value_;




- (NSString*)primitiveTip;
- (void)setPrimitiveTip:(NSString*)value;




- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;





- (NSMutableSet*)primitiveItems;
- (void)setPrimitiveItems:(NSMutableSet*)value;


@end
