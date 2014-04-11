// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MRSLComment.h instead.

#import <CoreData/CoreData.h>


extern const struct MRSLCommentAttributes {
	__unsafe_unretained NSString *commentDescription;
	__unsafe_unretained NSString *commentID;
	__unsafe_unretained NSString *creationDate;
} MRSLCommentAttributes;

extern const struct MRSLCommentRelationships {
	__unsafe_unretained NSString *creator;
	__unsafe_unretained NSString *item;
} MRSLCommentRelationships;

extern const struct MRSLCommentFetchedProperties {
} MRSLCommentFetchedProperties;

@class MRSLUser;
@class MRSLItem;





@interface MRSLCommentID : NSManagedObjectID {}
@end

@interface _MRSLComment : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MRSLCommentID*)objectID;





@property (nonatomic, strong) NSString* commentDescription;



//- (BOOL)validateCommentDescription:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* commentID;



@property int32_t commentIDValue;
- (int32_t)commentIDValue;
- (void)setCommentIDValue:(int32_t)value_;

//- (BOOL)validateCommentID:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* creationDate;



//- (BOOL)validateCreationDate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) MRSLUser *creator;

//- (BOOL)validateCreator:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) MRSLItem *item;

//- (BOOL)validateItem:(id*)value_ error:(NSError**)error_;





@end

@interface _MRSLComment (CoreDataGeneratedAccessors)

@end

@interface _MRSLComment (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveCommentDescription;
- (void)setPrimitiveCommentDescription:(NSString*)value;




- (NSNumber*)primitiveCommentID;
- (void)setPrimitiveCommentID:(NSNumber*)value;

- (int32_t)primitiveCommentIDValue;
- (void)setPrimitiveCommentIDValue:(int32_t)value_;




- (NSDate*)primitiveCreationDate;
- (void)setPrimitiveCreationDate:(NSDate*)value;





- (MRSLUser*)primitiveCreator;
- (void)setPrimitiveCreator:(MRSLUser*)value;



- (MRSLItem*)primitiveItem;
- (void)setPrimitiveItem:(MRSLItem*)value;


@end
