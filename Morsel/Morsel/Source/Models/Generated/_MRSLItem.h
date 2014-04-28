// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MRSLItem.h instead.

#import <CoreData/CoreData.h>


extern const struct MRSLItemAttributes {
	__unsafe_unretained NSString *comment_count;
	__unsafe_unretained NSString *creationDate;
	__unsafe_unretained NSString *creator_id;
	__unsafe_unretained NSString *didFailUpload;
	__unsafe_unretained NSString *isUploading;
	__unsafe_unretained NSString *itemDescription;
	__unsafe_unretained NSString *itemID;
	__unsafe_unretained NSString *itemPhotoCropped;
	__unsafe_unretained NSString *itemPhotoFull;
	__unsafe_unretained NSString *itemPhotoThumb;
	__unsafe_unretained NSString *itemPhotoURL;
	__unsafe_unretained NSString *lastUpdatedDate;
	__unsafe_unretained NSString *like_count;
	__unsafe_unretained NSString *liked;
	__unsafe_unretained NSString *likedDate;
	__unsafe_unretained NSString *localUUID;
	__unsafe_unretained NSString *photo_processing;
	__unsafe_unretained NSString *sort_order;
	__unsafe_unretained NSString *url;
} MRSLItemAttributes;

extern const struct MRSLItemRelationships {
	__unsafe_unretained NSString *activities;
	__unsafe_unretained NSString *comments;
	__unsafe_unretained NSString *morsel;
} MRSLItemRelationships;

extern const struct MRSLItemFetchedProperties {
} MRSLItemFetchedProperties;

@class MRSLActivity;
@class MRSLComment;
@class MRSLMorsel;





















@interface MRSLItemID : NSManagedObjectID {}
@end

@interface _MRSLItem : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MRSLItemID*)objectID;





@property (nonatomic, strong) NSNumber* comment_count;



@property int32_t comment_countValue;
- (int32_t)comment_countValue;
- (void)setComment_countValue:(int32_t)value_;

//- (BOOL)validateComment_count:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* creationDate;



//- (BOOL)validateCreationDate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* creator_id;



@property int32_t creator_idValue;
- (int32_t)creator_idValue;
- (void)setCreator_idValue:(int32_t)value_;

//- (BOOL)validateCreator_id:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* didFailUpload;



@property BOOL didFailUploadValue;
- (BOOL)didFailUploadValue;
- (void)setDidFailUploadValue:(BOOL)value_;

//- (BOOL)validateDidFailUpload:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* isUploading;



@property BOOL isUploadingValue;
- (BOOL)isUploadingValue;
- (void)setIsUploadingValue:(BOOL)value_;

//- (BOOL)validateIsUploading:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* itemDescription;



//- (BOOL)validateItemDescription:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* itemID;



@property int32_t itemIDValue;
- (int32_t)itemIDValue;
- (void)setItemIDValue:(int32_t)value_;

//- (BOOL)validateItemID:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSData* itemPhotoCropped;



//- (BOOL)validateItemPhotoCropped:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSData* itemPhotoFull;



//- (BOOL)validateItemPhotoFull:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSData* itemPhotoThumb;



//- (BOOL)validateItemPhotoThumb:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* itemPhotoURL;



//- (BOOL)validateItemPhotoURL:(id*)value_ error:(NSError**)error_;





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





@property (nonatomic, strong) NSDate* likedDate;



//- (BOOL)validateLikedDate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* localUUID;



//- (BOOL)validateLocalUUID:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* photo_processing;



@property BOOL photo_processingValue;
- (BOOL)photo_processingValue;
- (void)setPhoto_processingValue:(BOOL)value_;

//- (BOOL)validatePhoto_processing:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* sort_order;



@property int32_t sort_orderValue;
- (int32_t)sort_orderValue;
- (void)setSort_orderValue:(int32_t)value_;

//- (BOOL)validateSort_order:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* url;



//- (BOOL)validateUrl:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *activities;

- (NSMutableSet*)activitiesSet;




@property (nonatomic, strong) NSSet *comments;

- (NSMutableSet*)commentsSet;




@property (nonatomic, strong) MRSLMorsel *morsel;

//- (BOOL)validateMorsel:(id*)value_ error:(NSError**)error_;





@end

@interface _MRSLItem (CoreDataGeneratedAccessors)

- (void)addActivities:(NSSet*)value_;
- (void)removeActivities:(NSSet*)value_;
- (void)addActivitiesObject:(MRSLActivity*)value_;
- (void)removeActivitiesObject:(MRSLActivity*)value_;

- (void)addComments:(NSSet*)value_;
- (void)removeComments:(NSSet*)value_;
- (void)addCommentsObject:(MRSLComment*)value_;
- (void)removeCommentsObject:(MRSLComment*)value_;

@end

@interface _MRSLItem (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveComment_count;
- (void)setPrimitiveComment_count:(NSNumber*)value;

- (int32_t)primitiveComment_countValue;
- (void)setPrimitiveComment_countValue:(int32_t)value_;




- (NSDate*)primitiveCreationDate;
- (void)setPrimitiveCreationDate:(NSDate*)value;




- (NSNumber*)primitiveCreator_id;
- (void)setPrimitiveCreator_id:(NSNumber*)value;

- (int32_t)primitiveCreator_idValue;
- (void)setPrimitiveCreator_idValue:(int32_t)value_;




- (NSNumber*)primitiveDidFailUpload;
- (void)setPrimitiveDidFailUpload:(NSNumber*)value;

- (BOOL)primitiveDidFailUploadValue;
- (void)setPrimitiveDidFailUploadValue:(BOOL)value_;




- (NSNumber*)primitiveIsUploading;
- (void)setPrimitiveIsUploading:(NSNumber*)value;

- (BOOL)primitiveIsUploadingValue;
- (void)setPrimitiveIsUploadingValue:(BOOL)value_;




- (NSString*)primitiveItemDescription;
- (void)setPrimitiveItemDescription:(NSString*)value;




- (NSNumber*)primitiveItemID;
- (void)setPrimitiveItemID:(NSNumber*)value;

- (int32_t)primitiveItemIDValue;
- (void)setPrimitiveItemIDValue:(int32_t)value_;




- (NSData*)primitiveItemPhotoCropped;
- (void)setPrimitiveItemPhotoCropped:(NSData*)value;




- (NSData*)primitiveItemPhotoFull;
- (void)setPrimitiveItemPhotoFull:(NSData*)value;




- (NSData*)primitiveItemPhotoThumb;
- (void)setPrimitiveItemPhotoThumb:(NSData*)value;




- (NSString*)primitiveItemPhotoURL;
- (void)setPrimitiveItemPhotoURL:(NSString*)value;




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




- (NSDate*)primitiveLikedDate;
- (void)setPrimitiveLikedDate:(NSDate*)value;




- (NSString*)primitiveLocalUUID;
- (void)setPrimitiveLocalUUID:(NSString*)value;




- (NSNumber*)primitivePhoto_processing;
- (void)setPrimitivePhoto_processing:(NSNumber*)value;

- (BOOL)primitivePhoto_processingValue;
- (void)setPrimitivePhoto_processingValue:(BOOL)value_;




- (NSNumber*)primitiveSort_order;
- (void)setPrimitiveSort_order:(NSNumber*)value;

- (int32_t)primitiveSort_orderValue;
- (void)setPrimitiveSort_orderValue:(int32_t)value_;




- (NSString*)primitiveUrl;
- (void)setPrimitiveUrl:(NSString*)value;





- (NSMutableSet*)primitiveActivities;
- (void)setPrimitiveActivities:(NSMutableSet*)value;



- (NSMutableSet*)primitiveComments;
- (void)setPrimitiveComments:(NSMutableSet*)value;



- (MRSLMorsel*)primitiveMorsel;
- (void)setPrimitiveMorsel:(MRSLMorsel*)value;


@end
