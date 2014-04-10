// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MRSLPost.h instead.

#import <CoreData/CoreData.h>


extern const struct MRSLPostAttributes {
	__unsafe_unretained NSString *creationDate;
	__unsafe_unretained NSString *draft;
	__unsafe_unretained NSString *feedItemID;
	__unsafe_unretained NSString *lastUpdatedDate;
	__unsafe_unretained NSString *postID;
	__unsafe_unretained NSString *primary_morsel_id;
	__unsafe_unretained NSString *publishedDate;
	__unsafe_unretained NSString *title;
	__unsafe_unretained NSString *total_comment_count;
	__unsafe_unretained NSString *total_like_count;
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





@property (nonatomic, strong) NSNumber* feedItemID;



@property int32_t feedItemIDValue;
- (int32_t)feedItemIDValue;
- (void)setFeedItemIDValue:(int32_t)value_;

//- (BOOL)validateFeedItemID:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* lastUpdatedDate;



//- (BOOL)validateLastUpdatedDate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* postID;



@property int32_t postIDValue;
- (int32_t)postIDValue;
- (void)setPostIDValue:(int32_t)value_;

//- (BOOL)validatePostID:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* primary_morsel_id;



@property int32_t primary_morsel_idValue;
- (int32_t)primary_morsel_idValue;
- (void)setPrimary_morsel_idValue:(int32_t)value_;

//- (BOOL)validatePrimary_morsel_id:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* publishedDate;



//- (BOOL)validatePublishedDate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* title;



//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* total_comment_count;



@property int32_t total_comment_countValue;
- (int32_t)total_comment_countValue;
- (void)setTotal_comment_countValue:(int32_t)value_;

//- (BOOL)validateTotal_comment_count:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* total_like_count;



@property int32_t total_like_countValue;
- (int32_t)total_like_countValue;
- (void)setTotal_like_countValue:(int32_t)value_;

//- (BOOL)validateTotal_like_count:(id*)value_ error:(NSError**)error_;





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




- (NSNumber*)primitiveFeedItemID;
- (void)setPrimitiveFeedItemID:(NSNumber*)value;

- (int32_t)primitiveFeedItemIDValue;
- (void)setPrimitiveFeedItemIDValue:(int32_t)value_;




- (NSDate*)primitiveLastUpdatedDate;
- (void)setPrimitiveLastUpdatedDate:(NSDate*)value;




- (NSNumber*)primitivePostID;
- (void)setPrimitivePostID:(NSNumber*)value;

- (int32_t)primitivePostIDValue;
- (void)setPrimitivePostIDValue:(int32_t)value_;




- (NSNumber*)primitivePrimary_morsel_id;
- (void)setPrimitivePrimary_morsel_id:(NSNumber*)value;

- (int32_t)primitivePrimary_morsel_idValue;
- (void)setPrimitivePrimary_morsel_idValue:(int32_t)value_;




- (NSDate*)primitivePublishedDate;
- (void)setPrimitivePublishedDate:(NSDate*)value;




- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;




- (NSNumber*)primitiveTotal_comment_count;
- (void)setPrimitiveTotal_comment_count:(NSNumber*)value;

- (int32_t)primitiveTotal_comment_countValue;
- (void)setPrimitiveTotal_comment_countValue:(int32_t)value_;




- (NSNumber*)primitiveTotal_like_count;
- (void)setPrimitiveTotal_like_count:(NSNumber*)value;

- (int32_t)primitiveTotal_like_countValue;
- (void)setPrimitiveTotal_like_countValue:(int32_t)value_;





- (MRSLUser*)primitiveCreator;
- (void)setPrimitiveCreator:(MRSLUser*)value;



- (NSMutableSet*)primitiveMorsels;
- (void)setPrimitiveMorsels:(NSMutableSet*)value;


@end
