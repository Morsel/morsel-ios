// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MRSLMorsel.h instead.

#import <CoreData/CoreData.h>


extern const struct MRSLMorselAttributes {
	__unsafe_unretained NSString *creationDate;
	__unsafe_unretained NSString *morselDescription;
	__unsafe_unretained NSString *morselID;
	__unsafe_unretained NSString *morselPicture;
	__unsafe_unretained NSString *morselThumb;
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





@property (nonatomic, strong) NSString* morselDescription;



//- (BOOL)validateMorselDescription:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* morselID;



@property int16_t morselIDValue;
- (int16_t)morselIDValue;
- (void)setMorselIDValue:(int16_t)value_;

//- (BOOL)validateMorselID:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSData* morselPicture;



//- (BOOL)validateMorselPicture:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSData* morselThumb;



//- (BOOL)validateMorselThumb:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSOrderedSet *comments;

- (NSMutableOrderedSet*)commentsSet;




@property (nonatomic, strong) MRSLPost *post;

//- (BOOL)validatePost:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSSet *tags;

- (NSMutableSet*)tagsSet;





@end

@interface _MRSLMorsel (CoreDataGeneratedAccessors)

- (void)addComments:(NSOrderedSet*)value_;
- (void)removeComments:(NSOrderedSet*)value_;
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




- (NSString*)primitiveMorselDescription;
- (void)setPrimitiveMorselDescription:(NSString*)value;




- (NSNumber*)primitiveMorselID;
- (void)setPrimitiveMorselID:(NSNumber*)value;

- (int16_t)primitiveMorselIDValue;
- (void)setPrimitiveMorselIDValue:(int16_t)value_;




- (NSData*)primitiveMorselPicture;
- (void)setPrimitiveMorselPicture:(NSData*)value;




- (NSData*)primitiveMorselThumb;
- (void)setPrimitiveMorselThumb:(NSData*)value;





- (NSMutableOrderedSet*)primitiveComments;
- (void)setPrimitiveComments:(NSMutableOrderedSet*)value;



- (MRSLPost*)primitivePost;
- (void)setPrimitivePost:(MRSLPost*)value;



- (NSMutableSet*)primitiveTags;
- (void)setPrimitiveTags:(NSMutableSet*)value;


@end
