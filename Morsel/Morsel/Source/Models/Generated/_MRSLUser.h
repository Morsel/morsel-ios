// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MRSLUser.h instead.

#import <CoreData/CoreData.h>


extern const struct MRSLUserAttributes {
	__unsafe_unretained NSString *auth_token;
	__unsafe_unretained NSString *bio;
	__unsafe_unretained NSString *creationDate;
	__unsafe_unretained NSString *draft_count;
	__unsafe_unretained NSString *email;
	__unsafe_unretained NSString *facebook_uid;
	__unsafe_unretained NSString *first_name;
	__unsafe_unretained NSString *last_name;
	__unsafe_unretained NSString *like_count;
	__unsafe_unretained NSString *morsel_count;
	__unsafe_unretained NSString *profilePhoto;
	__unsafe_unretained NSString *profilePhotoURL;
	__unsafe_unretained NSString *title;
	__unsafe_unretained NSString *twitter_username;
	__unsafe_unretained NSString *userID;
	__unsafe_unretained NSString *username;
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





@property (nonatomic, strong) NSString* auth_token;



//- (BOOL)validateAuth_token:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* bio;



//- (BOOL)validateBio:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* creationDate;



//- (BOOL)validateCreationDate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* draft_count;



@property int16_t draft_countValue;
- (int16_t)draft_countValue;
- (void)setDraft_countValue:(int16_t)value_;

//- (BOOL)validateDraft_count:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* email;



//- (BOOL)validateEmail:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* facebook_uid;



//- (BOOL)validateFacebook_uid:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* first_name;



//- (BOOL)validateFirst_name:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* last_name;



//- (BOOL)validateLast_name:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* like_count;



@property int16_t like_countValue;
- (int16_t)like_countValue;
- (void)setLike_countValue:(int16_t)value_;

//- (BOOL)validateLike_count:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* morsel_count;



@property int16_t morsel_countValue;
- (int16_t)morsel_countValue;
- (void)setMorsel_countValue:(int16_t)value_;

//- (BOOL)validateMorsel_count:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSData* profilePhoto;



//- (BOOL)validateProfilePhoto:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* profilePhotoURL;



//- (BOOL)validateProfilePhotoURL:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* title;



//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* twitter_username;



//- (BOOL)validateTwitter_username:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* userID;



@property int16_t userIDValue;
- (int16_t)userIDValue;
- (void)setUserIDValue:(int16_t)value_;

//- (BOOL)validateUserID:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* username;



//- (BOOL)validateUsername:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *comments;

- (NSMutableSet*)commentsSet;




@property (nonatomic, strong) NSSet *posts;

- (NSMutableSet*)postsSet;





@end

@interface _MRSLUser (CoreDataGeneratedAccessors)

- (void)addComments:(NSSet*)value_;
- (void)removeComments:(NSSet*)value_;
- (void)addCommentsObject:(MRSLComment*)value_;
- (void)removeCommentsObject:(MRSLComment*)value_;

- (void)addPosts:(NSSet*)value_;
- (void)removePosts:(NSSet*)value_;
- (void)addPostsObject:(MRSLPost*)value_;
- (void)removePostsObject:(MRSLPost*)value_;

@end

@interface _MRSLUser (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveAuth_token;
- (void)setPrimitiveAuth_token:(NSString*)value;




- (NSString*)primitiveBio;
- (void)setPrimitiveBio:(NSString*)value;




- (NSDate*)primitiveCreationDate;
- (void)setPrimitiveCreationDate:(NSDate*)value;




- (NSNumber*)primitiveDraft_count;
- (void)setPrimitiveDraft_count:(NSNumber*)value;

- (int16_t)primitiveDraft_countValue;
- (void)setPrimitiveDraft_countValue:(int16_t)value_;




- (NSString*)primitiveEmail;
- (void)setPrimitiveEmail:(NSString*)value;




- (NSString*)primitiveFacebook_uid;
- (void)setPrimitiveFacebook_uid:(NSString*)value;




- (NSString*)primitiveFirst_name;
- (void)setPrimitiveFirst_name:(NSString*)value;




- (NSString*)primitiveLast_name;
- (void)setPrimitiveLast_name:(NSString*)value;




- (NSNumber*)primitiveLike_count;
- (void)setPrimitiveLike_count:(NSNumber*)value;

- (int16_t)primitiveLike_countValue;
- (void)setPrimitiveLike_countValue:(int16_t)value_;




- (NSNumber*)primitiveMorsel_count;
- (void)setPrimitiveMorsel_count:(NSNumber*)value;

- (int16_t)primitiveMorsel_countValue;
- (void)setPrimitiveMorsel_countValue:(int16_t)value_;




- (NSData*)primitiveProfilePhoto;
- (void)setPrimitiveProfilePhoto:(NSData*)value;




- (NSString*)primitiveProfilePhotoURL;
- (void)setPrimitiveProfilePhotoURL:(NSString*)value;




- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;




- (NSString*)primitiveTwitter_username;
- (void)setPrimitiveTwitter_username:(NSString*)value;




- (NSNumber*)primitiveUserID;
- (void)setPrimitiveUserID:(NSNumber*)value;

- (int16_t)primitiveUserIDValue;
- (void)setPrimitiveUserIDValue:(int16_t)value_;




- (NSString*)primitiveUsername;
- (void)setPrimitiveUsername:(NSString*)value;





- (NSMutableSet*)primitiveComments;
- (void)setPrimitiveComments:(NSMutableSet*)value;



- (NSMutableSet*)primitivePosts;
- (void)setPrimitivePosts:(NSMutableSet*)value;


@end
