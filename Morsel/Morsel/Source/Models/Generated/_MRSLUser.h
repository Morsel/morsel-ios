// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MRSLUser.h instead.

#import <CoreData/CoreData.h>


extern const struct MRSLUserAttributes {
	__unsafe_unretained NSString *emailAddress;
	__unsafe_unretained NSString *firstName;
	__unsafe_unretained NSString *lastName;
	__unsafe_unretained NSString *occupationType;
	__unsafe_unretained NSString *password;
	__unsafe_unretained NSString *profileImage;
	__unsafe_unretained NSString *userID;
} MRSLUserAttributes;

extern const struct MRSLUserRelationships {
	__unsafe_unretained NSString *comments;
	__unsafe_unretained NSString *posts;
} MRSLUserRelationships;

extern const struct MRSLUserFetchedProperties {
} MRSLUserFetchedProperties;

@class MRSLComment;
@class MRSLPost;









@interface MRSLUserID : NSManagedObjectID {}
@end

@interface _MRSLUser : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MRSLUserID*)objectID;





@property (nonatomic, strong) NSString* emailAddress;



//- (BOOL)validateEmailAddress:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* firstName;



//- (BOOL)validateFirstName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* lastName;



//- (BOOL)validateLastName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* occupationType;



@property int16_t occupationTypeValue;
- (int16_t)occupationTypeValue;
- (void)setOccupationTypeValue:(int16_t)value_;

//- (BOOL)validateOccupationType:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* password;



//- (BOOL)validatePassword:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSData* profileImage;



//- (BOOL)validateProfileImage:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* userID;



@property int16_t userIDValue;
- (int16_t)userIDValue;
- (void)setUserIDValue:(int16_t)value_;

//- (BOOL)validateUserID:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *comments;

- (NSMutableSet*)commentsSet;




@property (nonatomic, strong) NSOrderedSet *posts;

- (NSMutableOrderedSet*)postsSet;





@end

@interface _MRSLUser (CoreDataGeneratedAccessors)

- (void)addComments:(NSSet*)value_;
- (void)removeComments:(NSSet*)value_;
- (void)addCommentsObject:(MRSLComment*)value_;
- (void)removeCommentsObject:(MRSLComment*)value_;

- (void)addPosts:(NSOrderedSet*)value_;
- (void)removePosts:(NSOrderedSet*)value_;
- (void)addPostsObject:(MRSLPost*)value_;
- (void)removePostsObject:(MRSLPost*)value_;

@end

@interface _MRSLUser (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveEmailAddress;
- (void)setPrimitiveEmailAddress:(NSString*)value;




- (NSString*)primitiveFirstName;
- (void)setPrimitiveFirstName:(NSString*)value;




- (NSString*)primitiveLastName;
- (void)setPrimitiveLastName:(NSString*)value;




- (NSNumber*)primitiveOccupationType;
- (void)setPrimitiveOccupationType:(NSNumber*)value;

- (int16_t)primitiveOccupationTypeValue;
- (void)setPrimitiveOccupationTypeValue:(int16_t)value_;




- (NSString*)primitivePassword;
- (void)setPrimitivePassword:(NSString*)value;




- (NSData*)primitiveProfileImage;
- (void)setPrimitiveProfileImage:(NSData*)value;




- (NSNumber*)primitiveUserID;
- (void)setPrimitiveUserID:(NSNumber*)value;

- (int16_t)primitiveUserIDValue;
- (void)setPrimitiveUserIDValue:(int16_t)value_;





- (NSMutableSet*)primitiveComments;
- (void)setPrimitiveComments:(NSMutableSet*)value;



- (NSMutableOrderedSet*)primitivePosts;
- (void)setPrimitivePosts:(NSMutableOrderedSet*)value;


@end
