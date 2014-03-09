// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MRSLPost.h instead.

#import <CoreData/CoreData.h>


extern const struct MRSLPostAttributes {
	__unsafe_unretained NSString *creationDate;
	__unsafe_unretained NSString *draft;
	__unsafe_unretained NSString *lastUpdatedDate;
	__unsafe_unretained NSString *postID;
	__unsafe_unretained NSString *title;
} MRSLPostAttributes;

extern const struct MRSLPostRelationships {
	__unsafe_unretained NSString *creator;
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





@property (nonatomic, strong) NSDate* lastUpdatedDate;



//- (BOOL)validateLastUpdatedDate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* postID;



@property int16_t postIDValue;
- (int16_t)postIDValue;
- (void)setPostIDValue:(int16_t)value_;

//- (BOOL)validatePostID:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* title;



//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) MRSLUser *creator;

//- (BOOL)validateCreator:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSSet *morsels;

- (NSMutableSet*)morselsSet;





@end

@interface _MRSLPost (CoreDataGeneratedAccessors)

- (void)addMorsels:(NSSet*)value_;
- (void)removeMorsels:(NSSet*)value_;
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




- (NSDate*)primitiveLastUpdatedDate;
- (void)setPrimitiveLastUpdatedDate:(NSDate*)value;




- (NSNumber*)primitivePostID;
- (void)setPrimitivePostID:(NSNumber*)value;

- (int16_t)primitivePostIDValue;
- (void)setPrimitivePostIDValue:(int16_t)value_;




- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;





- (MRSLUser*)primitiveCreator;
- (void)setPrimitiveCreator:(MRSLUser*)value;



- (NSMutableSet*)primitiveMorsels;
- (void)setPrimitiveMorsels:(NSMutableSet*)value;


@end
