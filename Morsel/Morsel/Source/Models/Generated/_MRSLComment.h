// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MRSLComment.h instead.

#import <CoreData/CoreData.h>


extern const struct MRSLCommentAttributes {
	__unsafe_unretained NSString *commentID;
	__unsafe_unretained NSString *creationDate;
	__unsafe_unretained NSString *text;
} MRSLCommentAttributes;

extern const struct MRSLCommentRelationships {
	__unsafe_unretained NSString *morsel;
	__unsafe_unretained NSString *user;
} MRSLCommentRelationships;

extern const struct MRSLCommentFetchedProperties {
} MRSLCommentFetchedProperties;

@class MRSLMorsel;
@class MRSLUser;





@interface MRSLCommentID : NSManagedObjectID {}
@end

@interface _MRSLComment : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MRSLCommentID*)objectID;





@property (nonatomic, strong) NSNumber* commentID;



@property int16_t commentIDValue;
- (int16_t)commentIDValue;
- (void)setCommentIDValue:(int16_t)value_;

//- (BOOL)validateCommentID:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* creationDate;



//- (BOOL)validateCreationDate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* text;



//- (BOOL)validateText:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) MRSLMorsel *morsel;

//- (BOOL)validateMorsel:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) MRSLUser *user;

//- (BOOL)validateUser:(id*)value_ error:(NSError**)error_;





@end

@interface _MRSLComment (CoreDataGeneratedAccessors)

@end

@interface _MRSLComment (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveCommentID;
- (void)setPrimitiveCommentID:(NSNumber*)value;

- (int16_t)primitiveCommentIDValue;
- (void)setPrimitiveCommentIDValue:(int16_t)value_;




- (NSString*)primitiveCreationDate;
- (void)setPrimitiveCreationDate:(NSString*)value;




- (NSString*)primitiveText;
- (void)setPrimitiveText:(NSString*)value;





- (MRSLMorsel*)primitiveMorsel;
- (void)setPrimitiveMorsel:(MRSLMorsel*)value;



- (MRSLUser*)primitiveUser;
- (void)setPrimitiveUser:(MRSLUser*)value;


@end
