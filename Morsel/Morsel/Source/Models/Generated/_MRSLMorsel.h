// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MRSLMorsel.h instead.

#import <CoreData/CoreData.h>


extern const struct MRSLMorselAttributes {
	__unsafe_unretained NSString *creationDate;
	__unsafe_unretained NSString *draft;
	__unsafe_unretained NSString *facebook_mrsl;
	__unsafe_unretained NSString *feedItemID;
	__unsafe_unretained NSString *lastUpdatedDate;
	__unsafe_unretained NSString *morselID;
	__unsafe_unretained NSString *morselPhotoURL;
	__unsafe_unretained NSString *primary_item_id;
	__unsafe_unretained NSString *publishedDate;
	__unsafe_unretained NSString *title;
	__unsafe_unretained NSString *total_comment_count;
	__unsafe_unretained NSString *total_like_count;
	__unsafe_unretained NSString *twitter_mrsl;
	__unsafe_unretained NSString *url;
} MRSLMorselAttributes;

extern const struct MRSLMorselRelationships {
	__unsafe_unretained NSString *creator;
	__unsafe_unretained NSString *items;
} MRSLMorselRelationships;

extern const struct MRSLMorselFetchedProperties {
} MRSLMorselFetchedProperties;

@class MRSLUser;
@class MRSLItem;
















@interface MRSLMorselID : NSManagedObjectID {}
@end

@interface _MRSLMorsel : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MRSLMorselID*)objectID;





@property (nonatomic, strong) NSDate* creationDate;



//- (BOOL)validateCreationDate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* draft;



@property BOOL draftValue;
- (BOOL)draftValue;
- (void)setDraftValue:(BOOL)value_;

//- (BOOL)validateDraft:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* facebook_mrsl;



//- (BOOL)validateFacebook_mrsl:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* feedItemID;



@property int32_t feedItemIDValue;
- (int32_t)feedItemIDValue;
- (void)setFeedItemIDValue:(int32_t)value_;

//- (BOOL)validateFeedItemID:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* lastUpdatedDate;



//- (BOOL)validateLastUpdatedDate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* morselID;



@property int32_t morselIDValue;
- (int32_t)morselIDValue;
- (void)setMorselIDValue:(int32_t)value_;

//- (BOOL)validateMorselID:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* morselPhotoURL;



//- (BOOL)validateMorselPhotoURL:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* primary_item_id;



@property int32_t primary_item_idValue;
- (int32_t)primary_item_idValue;
- (void)setPrimary_item_idValue:(int32_t)value_;

//- (BOOL)validatePrimary_item_id:(id*)value_ error:(NSError**)error_;





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





@property (nonatomic, strong) NSString* twitter_mrsl;



//- (BOOL)validateTwitter_mrsl:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* url;



//- (BOOL)validateUrl:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) MRSLUser *creator;

//- (BOOL)validateCreator:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSSet *items;

- (NSMutableSet*)itemsSet;





@end

@interface _MRSLMorsel (CoreDataGeneratedAccessors)

- (void)addItems:(NSSet*)value_;
- (void)removeItems:(NSSet*)value_;
- (void)addItemsObject:(MRSLItem*)value_;
- (void)removeItemsObject:(MRSLItem*)value_;

@end

@interface _MRSLMorsel (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveCreationDate;
- (void)setPrimitiveCreationDate:(NSDate*)value;




- (NSNumber*)primitiveDraft;
- (void)setPrimitiveDraft:(NSNumber*)value;

- (BOOL)primitiveDraftValue;
- (void)setPrimitiveDraftValue:(BOOL)value_;




- (NSString*)primitiveFacebook_mrsl;
- (void)setPrimitiveFacebook_mrsl:(NSString*)value;




- (NSNumber*)primitiveFeedItemID;
- (void)setPrimitiveFeedItemID:(NSNumber*)value;

- (int32_t)primitiveFeedItemIDValue;
- (void)setPrimitiveFeedItemIDValue:(int32_t)value_;




- (NSDate*)primitiveLastUpdatedDate;
- (void)setPrimitiveLastUpdatedDate:(NSDate*)value;




- (NSNumber*)primitiveMorselID;
- (void)setPrimitiveMorselID:(NSNumber*)value;

- (int32_t)primitiveMorselIDValue;
- (void)setPrimitiveMorselIDValue:(int32_t)value_;




- (NSString*)primitiveMorselPhotoURL;
- (void)setPrimitiveMorselPhotoURL:(NSString*)value;




- (NSNumber*)primitivePrimary_item_id;
- (void)setPrimitivePrimary_item_id:(NSNumber*)value;

- (int32_t)primitivePrimary_item_idValue;
- (void)setPrimitivePrimary_item_idValue:(int32_t)value_;




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




- (NSString*)primitiveTwitter_mrsl;
- (void)setPrimitiveTwitter_mrsl:(NSString*)value;




- (NSString*)primitiveUrl;
- (void)setPrimitiveUrl:(NSString*)value;





- (MRSLUser*)primitiveCreator;
- (void)setPrimitiveCreator:(MRSLUser*)value;



- (NSMutableSet*)primitiveItems;
- (void)setPrimitiveItems:(NSMutableSet*)value;


@end
