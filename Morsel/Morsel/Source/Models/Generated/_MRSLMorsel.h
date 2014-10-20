// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MRSLMorsel.h instead.

#import <CoreData/CoreData.h>


extern const struct MRSLMorselAttributes {
	__unsafe_unretained NSString *clipboard_mrsl;
	__unsafe_unretained NSString *creationDate;
	__unsafe_unretained NSString *draft;
	__unsafe_unretained NSString *facebook_mrsl;
	__unsafe_unretained NSString *feedItemFeatured;
	__unsafe_unretained NSString *feedItemID;
	__unsafe_unretained NSString *has_tagged_users;
	__unsafe_unretained NSString *lastUpdatedDate;
	__unsafe_unretained NSString *like_count;
	__unsafe_unretained NSString *liked;
	__unsafe_unretained NSString *morselID;
	__unsafe_unretained NSString *morselPhotoURL;
	__unsafe_unretained NSString *primary_item_id;
	__unsafe_unretained NSString *publishedDate;
	__unsafe_unretained NSString *tagged;
	__unsafe_unretained NSString *template_id;
	__unsafe_unretained NSString *title;
	__unsafe_unretained NSString *twitter_mrsl;
	__unsafe_unretained NSString *url;
} MRSLMorselAttributes;

extern const struct MRSLMorselRelationships {
	__unsafe_unretained NSString *activitiesAsSubject;
	__unsafe_unretained NSString *creator;
	__unsafe_unretained NSString *items;
	__unsafe_unretained NSString *place;
} MRSLMorselRelationships;

extern const struct MRSLMorselFetchedProperties {
} MRSLMorselFetchedProperties;

@class MRSLActivity;
@class MRSLUser;
@class MRSLItem;
@class MRSLPlace;





















@interface MRSLMorselID : NSManagedObjectID {}
@end

@interface _MRSLMorsel : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MRSLMorselID*)objectID;





@property (nonatomic, strong) NSString* clipboard_mrsl;



//- (BOOL)validateClipboard_mrsl:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* creationDate;



//- (BOOL)validateCreationDate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* draft;



@property BOOL draftValue;
- (BOOL)draftValue;
- (void)setDraftValue:(BOOL)value_;

//- (BOOL)validateDraft:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* facebook_mrsl;



//- (BOOL)validateFacebook_mrsl:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* feedItemFeatured;



@property BOOL feedItemFeaturedValue;
- (BOOL)feedItemFeaturedValue;
- (void)setFeedItemFeaturedValue:(BOOL)value_;

//- (BOOL)validateFeedItemFeatured:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* feedItemID;



@property int32_t feedItemIDValue;
- (int32_t)feedItemIDValue;
- (void)setFeedItemIDValue:(int32_t)value_;

//- (BOOL)validateFeedItemID:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* has_tagged_users;



@property BOOL has_tagged_usersValue;
- (BOOL)has_tagged_usersValue;
- (void)setHas_tagged_usersValue:(BOOL)value_;

//- (BOOL)validateHas_tagged_users:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* lastUpdatedDate;



//- (BOOL)validateLastUpdatedDate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* like_count;



@property int32_t like_countValue;
- (int32_t)like_countValue;
- (void)setLike_countValue:(int32_t)value_;

//- (BOOL)validateLike_count:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* liked;



@property BOOL likedValue;
- (BOOL)likedValue;
- (void)setLikedValue:(BOOL)value_;

//- (BOOL)validateLiked:(id*)value_ error:(NSError**)error_;





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





@property (nonatomic, strong) NSNumber* tagged;



@property BOOL taggedValue;
- (BOOL)taggedValue;
- (void)setTaggedValue:(BOOL)value_;

//- (BOOL)validateTagged:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* template_id;



@property int16_t template_idValue;
- (int16_t)template_idValue;
- (void)setTemplate_idValue:(int16_t)value_;

//- (BOOL)validateTemplate_id:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* title;



//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* twitter_mrsl;



//- (BOOL)validateTwitter_mrsl:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* url;



//- (BOOL)validateUrl:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *activitiesAsSubject;

- (NSMutableSet*)activitiesAsSubjectSet;




@property (nonatomic, strong) MRSLUser *creator;

//- (BOOL)validateCreator:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSSet *items;

- (NSMutableSet*)itemsSet;




@property (nonatomic, strong) MRSLPlace *place;

//- (BOOL)validatePlace:(id*)value_ error:(NSError**)error_;





@end

@interface _MRSLMorsel (CoreDataGeneratedAccessors)

- (void)addActivitiesAsSubject:(NSSet*)value_;
- (void)removeActivitiesAsSubject:(NSSet*)value_;
- (void)addActivitiesAsSubjectObject:(MRSLActivity*)value_;
- (void)removeActivitiesAsSubjectObject:(MRSLActivity*)value_;

- (void)addItems:(NSSet*)value_;
- (void)removeItems:(NSSet*)value_;
- (void)addItemsObject:(MRSLItem*)value_;
- (void)removeItemsObject:(MRSLItem*)value_;

@end

@interface _MRSLMorsel (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveClipboard_mrsl;
- (void)setPrimitiveClipboard_mrsl:(NSString*)value;




- (NSDate*)primitiveCreationDate;
- (void)setPrimitiveCreationDate:(NSDate*)value;




- (NSNumber*)primitiveDraft;
- (void)setPrimitiveDraft:(NSNumber*)value;

- (BOOL)primitiveDraftValue;
- (void)setPrimitiveDraftValue:(BOOL)value_;




- (NSString*)primitiveFacebook_mrsl;
- (void)setPrimitiveFacebook_mrsl:(NSString*)value;




- (NSNumber*)primitiveFeedItemFeatured;
- (void)setPrimitiveFeedItemFeatured:(NSNumber*)value;

- (BOOL)primitiveFeedItemFeaturedValue;
- (void)setPrimitiveFeedItemFeaturedValue:(BOOL)value_;




- (NSNumber*)primitiveFeedItemID;
- (void)setPrimitiveFeedItemID:(NSNumber*)value;

- (int32_t)primitiveFeedItemIDValue;
- (void)setPrimitiveFeedItemIDValue:(int32_t)value_;




- (NSNumber*)primitiveHas_tagged_users;
- (void)setPrimitiveHas_tagged_users:(NSNumber*)value;

- (BOOL)primitiveHas_tagged_usersValue;
- (void)setPrimitiveHas_tagged_usersValue:(BOOL)value_;




- (NSDate*)primitiveLastUpdatedDate;
- (void)setPrimitiveLastUpdatedDate:(NSDate*)value;




- (NSNumber*)primitiveLike_count;
- (void)setPrimitiveLike_count:(NSNumber*)value;

- (int32_t)primitiveLike_countValue;
- (void)setPrimitiveLike_countValue:(int32_t)value_;




- (NSNumber*)primitiveLiked;
- (void)setPrimitiveLiked:(NSNumber*)value;

- (BOOL)primitiveLikedValue;
- (void)setPrimitiveLikedValue:(BOOL)value_;




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




- (NSNumber*)primitiveTagged;
- (void)setPrimitiveTagged:(NSNumber*)value;

- (BOOL)primitiveTaggedValue;
- (void)setPrimitiveTaggedValue:(BOOL)value_;




- (NSNumber*)primitiveTemplate_id;
- (void)setPrimitiveTemplate_id:(NSNumber*)value;

- (int16_t)primitiveTemplate_idValue;
- (void)setPrimitiveTemplate_idValue:(int16_t)value_;




- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;




- (NSString*)primitiveTwitter_mrsl;
- (void)setPrimitiveTwitter_mrsl:(NSString*)value;




- (NSString*)primitiveUrl;
- (void)setPrimitiveUrl:(NSString*)value;





- (NSMutableSet*)primitiveActivitiesAsSubject;
- (void)setPrimitiveActivitiesAsSubject:(NSMutableSet*)value;



- (MRSLUser*)primitiveCreator;
- (void)setPrimitiveCreator:(MRSLUser*)value;



- (NSMutableSet*)primitiveItems;
- (void)setPrimitiveItems:(NSMutableSet*)value;



- (MRSLPlace*)primitivePlace;
- (void)setPrimitivePlace:(MRSLPlace*)value;


@end
