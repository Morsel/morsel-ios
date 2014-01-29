// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MRSLUser.h instead.

#import <CoreData/CoreData.h>


extern const struct MRSLUserAttributes {
	__unsafe_unretained NSString *authToken;
	__unsafe_unretained NSString *bio;
	__unsafe_unretained NSString *emailAddress;
	__unsafe_unretained NSString *firstName;
	__unsafe_unretained NSString *lastName;
	__unsafe_unretained NSString *likeCount;
	__unsafe_unretained NSString *morselCount;
	__unsafe_unretained NSString *occupationTitle;
	__unsafe_unretained NSString *occupationType;
	__unsafe_unretained NSString *profileImage;
	__unsafe_unretained NSString *profileImageURL;
	__unsafe_unretained NSString *userID;
	__unsafe_unretained NSString *userName;
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





@property (nonatomic, strong) NSString* authToken;



//- (BOOL)validateAuthToken:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* bio;



//- (BOOL)validateBio:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* emailAddress;



//- (BOOL)validateEmailAddress:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* firstName;



//- (BOOL)validateFirstName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* lastName;



//- (BOOL)validateLastName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* likeCount;



@property int16_t likeCountValue;
- (int16_t)likeCountValue;
- (void)setLikeCountValue:(int16_t)value_;

//- (BOOL)validateLikeCount:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* morselCount;



@property int16_t morselCountValue;
- (int16_t)morselCountValue;
- (void)setMorselCountValue:(int16_t)value_;

//- (BOOL)validateMorselCount:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* occupationTitle;



//- (BOOL)validateOccupationTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* occupationType;



@property int16_t occupationTypeValue;
- (int16_t)occupationTypeValue;
- (void)setOccupationTypeValue:(int16_t)value_;

//- (BOOL)validateOccupationType:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSData* profileImage;



//- (BOOL)validateProfileImage:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* profileImageURL;



//- (BOOL)validateProfileImageURL:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* userID;



@property int16_t userIDValue;
- (int16_t)userIDValue;
- (void)setUserIDValue:(int16_t)value_;

//- (BOOL)validateUserID:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* userName;



//- (BOOL)validateUserName:(id*)value_ error:(NSError**)error_;





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


- (NSString*)primitiveAuthToken;
- (void)setPrimitiveAuthToken:(NSString*)value;




- (NSString*)primitiveBio;
- (void)setPrimitiveBio:(NSString*)value;




- (NSString*)primitiveEmailAddress;
- (void)setPrimitiveEmailAddress:(NSString*)value;




- (NSString*)primitiveFirstName;
- (void)setPrimitiveFirstName:(NSString*)value;




- (NSString*)primitiveLastName;
- (void)setPrimitiveLastName:(NSString*)value;




- (NSNumber*)primitiveLikeCount;
- (void)setPrimitiveLikeCount:(NSNumber*)value;

- (int16_t)primitiveLikeCountValue;
- (void)setPrimitiveLikeCountValue:(int16_t)value_;




- (NSNumber*)primitiveMorselCount;
- (void)setPrimitiveMorselCount:(NSNumber*)value;

- (int16_t)primitiveMorselCountValue;
- (void)setPrimitiveMorselCountValue:(int16_t)value_;




- (NSString*)primitiveOccupationTitle;
- (void)setPrimitiveOccupationTitle:(NSString*)value;




- (NSNumber*)primitiveOccupationType;
- (void)setPrimitiveOccupationType:(NSNumber*)value;

- (int16_t)primitiveOccupationTypeValue;
- (void)setPrimitiveOccupationTypeValue:(int16_t)value_;




- (NSData*)primitiveProfileImage;
- (void)setPrimitiveProfileImage:(NSData*)value;




- (NSString*)primitiveProfileImageURL;
- (void)setPrimitiveProfileImageURL:(NSString*)value;




- (NSNumber*)primitiveUserID;
- (void)setPrimitiveUserID:(NSNumber*)value;

- (int16_t)primitiveUserIDValue;
- (void)setPrimitiveUserIDValue:(int16_t)value_;




- (NSString*)primitiveUserName;
- (void)setPrimitiveUserName:(NSString*)value;





- (NSMutableSet*)primitiveComments;
- (void)setPrimitiveComments:(NSMutableSet*)value;



- (NSMutableOrderedSet*)primitivePosts;
- (void)setPrimitivePosts:(NSMutableOrderedSet*)value;


@end
