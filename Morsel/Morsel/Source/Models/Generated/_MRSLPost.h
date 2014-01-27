// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MRSLPost.h instead.

#import <CoreData/CoreData.h>


extern const struct MRSLPostAttributes {
	__unsafe_unretained NSString *creationDate;
	__unsafe_unretained NSString *draft;
	__unsafe_unretained NSString *editing;
	__unsafe_unretained NSString *postID;
	__unsafe_unretained NSString *title;
} MRSLPostAttributes;

extern const struct MRSLPostRelationships {
	__unsafe_unretained NSString *author;
	__unsafe_unretained NSString *morsels;
} MRSLPostRelationships;

extern const struct MRSLPostFetchedProperties {
} MRSLPostFetchedProperties;

@class MRSLUser;
@class MRSLMorsel;







@interface MRSLPostID : NSManagedObjectID {}
@end

@interface _MRSLPost : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MRSLPostID*)objectID;





@property (nonatomic, strong) NSDate* creationDate;



//- (BOOL)validateCreationDate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* draft;



@property BOOL draftValue;
- (BOOL)draftValue;
- (void)setDraftValue:(BOOL)value_;

//- (BOOL)validateDraft:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* editing;



@property BOOL editingValue;
- (BOOL)editingValue;
- (void)setEditingValue:(BOOL)value_;

//- (BOOL)validateEditing:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* postID;



@property int16_t postIDValue;
- (int16_t)postIDValue;
- (void)setPostIDValue:(int16_t)value_;

//- (BOOL)validatePostID:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* title;



//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) MRSLUser *author;

//- (BOOL)validateAuthor:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSOrderedSet *morsels;

- (NSMutableOrderedSet*)morselsSet;





@end

@interface _MRSLPost (CoreDataGeneratedAccessors)

- (void)addMorsels:(NSOrderedSet*)value_;
- (void)removeMorsels:(NSOrderedSet*)value_;
- (void)addMorselsObject:(MRSLMorsel*)value_;
- (void)removeMorselsObject:(MRSLMorsel*)value_;

@end

@interface _MRSLPost (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveCreationDate;
- (void)setPrimitiveCreationDate:(NSDate*)value;




- (NSNumber*)primitiveDraft;
- (void)setPrimitiveDraft:(NSNumber*)value;

- (BOOL)primitiveDraftValue;
- (void)setPrimitiveDraftValue:(BOOL)value_;




- (NSNumber*)primitiveEditing;
- (void)setPrimitiveEditing:(NSNumber*)value;

- (BOOL)primitiveEditingValue;
- (void)setPrimitiveEditingValue:(BOOL)value_;




- (NSNumber*)primitivePostID;
- (void)setPrimitivePostID:(NSNumber*)value;

- (int16_t)primitivePostIDValue;
- (void)setPrimitivePostIDValue:(int16_t)value_;




- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;





- (MRSLUser*)primitiveAuthor;
- (void)setPrimitiveAuthor:(MRSLUser*)value;



- (NSMutableOrderedSet*)primitiveMorsels;
- (void)setPrimitiveMorsels:(NSMutableOrderedSet*)value;


@end
