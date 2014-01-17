// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MRSLMorsel.h instead.

#import <CoreData/CoreData.h>


extern const struct MRSLMorselAttributes {
	__unsafe_unretained NSString *creationDate;
	__unsafe_unretained NSString *liked;
	__unsafe_unretained NSString *morselDescription;
	__unsafe_unretained NSString *morselID;
	__unsafe_unretained NSString *morselPicture;
	__unsafe_unretained NSString *morselPictureURL;
	__unsafe_unretained NSString *morselThumb;
	__unsafe_unretained NSString *morselThumbURL;
	__unsafe_unretained NSString *sortOrder;
} MRSLMorselAttributes;

extern const struct MRSLMorselRelationships {
	__unsafe_unretained NSString *comments;
	__unsafe_unretained NSString *post;
	__unsafe_unretained NSString *tags;
} MRSLMorselRelationships;

extern const struct MRSLMorselFetchedProperties {
} MRSLMorselFetchedProperties;

@class MRSLComment;
@class MRSLPost;
@class MRSLTag;











@interface MRSLMorselID : NSManagedObjectID {}
@end

@interface _MRSLMorsel : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MRSLMorselID*)objectID;





@property (nonatomic, strong) NSDate* creationDate;



//- (BOOL)validateCreationDate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* liked;



@property BOOL likedValue;
- (BOOL)likedValue;
- (void)setLikedValue:(BOOL)value_;

//- (BOOL)validateLiked:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* morselDescription;



//- (BOOL)validateMorselDescription:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* morselID;



@property int16_t morselIDValue;
- (int16_t)morselIDValue;
- (void)setMorselIDValue:(int16_t)value_;

//- (BOOL)validateMorselID:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSData* morselPicture;



//- (BOOL)validateMorselPicture:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* morselPictureURL;



//- (BOOL)validateMorselPictureURL:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSData* morselThumb;



//- (BOOL)validateMorselThumb:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* morselThumbURL;



//- (BOOL)validateMorselThumbURL:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* sortOrder;



@property int16_t sortOrderValue;
- (int16_t)sortOrderValue;
- (void)setSortOrderValue:(int16_t)value_;

//- (BOOL)validateSortOrder:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *comments;

- (NSMutableSet*)commentsSet;




@property (nonatomic, strong) MRSLPost *post;

//- (BOOL)validatePost:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSSet *tags;

- (NSMutableSet*)tagsSet;





@end

@interface _MRSLMorsel (CoreDataGeneratedAccessors)

- (void)addComments:(NSSet*)value_;
- (void)removeComments:(NSSet*)value_;
- (void)addCommentsObject:(MRSLComment*)value_;
- (void)removeCommentsObject:(MRSLComment*)value_;

- (void)addTags:(NSSet*)value_;
- (void)removeTags:(NSSet*)value_;
- (void)addTagsObject:(MRSLTag*)value_;
- (void)removeTagsObject:(MRSLTag*)value_;

@end

@interface _MRSLMorsel (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveCreationDate;
- (void)setPrimitiveCreationDate:(NSDate*)value;




- (NSNumber*)primitiveLiked;
- (void)setPrimitiveLiked:(NSNumber*)value;

- (BOOL)primitiveLikedValue;
- (void)setPrimitiveLikedValue:(BOOL)value_;




- (NSString*)primitiveMorselDescription;
- (void)setPrimitiveMorselDescription:(NSString*)value;




- (NSNumber*)primitiveMorselID;
- (void)setPrimitiveMorselID:(NSNumber*)value;

- (int16_t)primitiveMorselIDValue;
- (void)setPrimitiveMorselIDValue:(int16_t)value_;




- (NSData*)primitiveMorselPicture;
- (void)setPrimitiveMorselPicture:(NSData*)value;




- (NSString*)primitiveMorselPictureURL;
- (void)setPrimitiveMorselPictureURL:(NSString*)value;




- (NSData*)primitiveMorselThumb;
- (void)setPrimitiveMorselThumb:(NSData*)value;




- (NSString*)primitiveMorselThumbURL;
- (void)setPrimitiveMorselThumbURL:(NSString*)value;




- (NSNumber*)primitiveSortOrder;
- (void)setPrimitiveSortOrder:(NSNumber*)value;

- (int16_t)primitiveSortOrderValue;
- (void)setPrimitiveSortOrderValue:(int16_t)value_;





- (NSMutableSet*)primitiveComments;
- (void)setPrimitiveComments:(NSMutableSet*)value;



- (MRSLPost*)primitivePost;
- (void)setPrimitivePost:(MRSLPost*)value;



- (NSMutableSet*)primitiveTags;
- (void)setPrimitiveTags:(NSMutableSet*)value;


@end
