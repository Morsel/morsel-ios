// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MRSLUser.h instead.

#import <CoreData/CoreData.h>


extern const struct MRSLUserAttributes {
	__unsafe_unretained NSString *auth_token;
	__unsafe_unretained NSString *bio;
	__unsafe_unretained NSString *creationDate;
	__unsafe_unretained NSString *dateFollowed;
	__unsafe_unretained NSString *draft_count;
	__unsafe_unretained NSString *email;
	__unsafe_unretained NSString *facebook_uid;
	__unsafe_unretained NSString *first_name;
	__unsafe_unretained NSString *followed_users_count;
	__unsafe_unretained NSString *follower_count;
	__unsafe_unretained NSString *following;
	__unsafe_unretained NSString *industry;
	__unsafe_unretained NSString *last_name;
	__unsafe_unretained NSString *liked_items_count;
	__unsafe_unretained NSString *morsel_count;
	__unsafe_unretained NSString *profilePhotoFull;
	__unsafe_unretained NSString *profilePhotoLarge;
	__unsafe_unretained NSString *profilePhotoThumb;
	__unsafe_unretained NSString *profilePhotoURL;
	__unsafe_unretained NSString *staff;
	__unsafe_unretained NSString *twitter_username;
	__unsafe_unretained NSString *userID;
	__unsafe_unretained NSString *username;
} MRSLUserAttributes;

extern const struct MRSLUserRelationships {
	__unsafe_unretained NSString *activities;
	__unsafe_unretained NSString *comments;
	__unsafe_unretained NSString *morsels;
	__unsafe_unretained NSString *tags;
} MRSLUserRelationships;

extern const struct MRSLUserFetchedProperties {
} MRSLUserFetchedProperties;

@class MRSLActivity;
@class MRSLComment;
@class MRSLMorsel;
@class MRSLTag;

























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





@property (nonatomic, strong) NSDate* dateFollowed;



//- (BOOL)validateDateFollowed:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* draft_count;



@property int32_t draft_countValue;
- (int32_t)draft_countValue;
- (void)setDraft_countValue:(int32_t)value_;

//- (BOOL)validateDraft_count:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* email;



//- (BOOL)validateEmail:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* facebook_uid;



//- (BOOL)validateFacebook_uid:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* first_name;



//- (BOOL)validateFirst_name:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* followed_users_count;



@property int32_t followed_users_countValue;
- (int32_t)followed_users_countValue;
- (void)setFollowed_users_countValue:(int32_t)value_;

//- (BOOL)validateFollowed_users_count:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* follower_count;



@property int32_t follower_countValue;
- (int32_t)follower_countValue;
- (void)setFollower_countValue:(int32_t)value_;

//- (BOOL)validateFollower_count:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* following;



@property BOOL followingValue;
- (BOOL)followingValue;
- (void)setFollowingValue:(BOOL)value_;

//- (BOOL)validateFollowing:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* industry;



//- (BOOL)validateIndustry:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* last_name;



//- (BOOL)validateLast_name:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* liked_items_count;



@property int32_t liked_items_countValue;
- (int32_t)liked_items_countValue;
- (void)setLiked_items_countValue:(int32_t)value_;

//- (BOOL)validateLiked_items_count:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* morsel_count;



@property int32_t morsel_countValue;
- (int32_t)morsel_countValue;
- (void)setMorsel_countValue:(int32_t)value_;

//- (BOOL)validateMorsel_count:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSData* profilePhotoFull;



//- (BOOL)validateProfilePhotoFull:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSData* profilePhotoLarge;



//- (BOOL)validateProfilePhotoLarge:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSData* profilePhotoThumb;



//- (BOOL)validateProfilePhotoThumb:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* profilePhotoURL;



//- (BOOL)validateProfilePhotoURL:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* staff;



@property BOOL staffValue;
- (BOOL)staffValue;
- (void)setStaffValue:(BOOL)value_;

//- (BOOL)validateStaff:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* twitter_username;



//- (BOOL)validateTwitter_username:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* userID;



@property int32_t userIDValue;
- (int32_t)userIDValue;
- (void)setUserIDValue:(int32_t)value_;

//- (BOOL)validateUserID:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* username;



//- (BOOL)validateUsername:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) MRSLActivity *activities;

//- (BOOL)validateActivities:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSSet *comments;

- (NSMutableSet*)commentsSet;




@property (nonatomic, strong) NSSet *morsels;

- (NSMutableSet*)morselsSet;




@property (nonatomic, strong) NSSet *tags;

- (NSMutableSet*)tagsSet;





@end

@interface _MRSLUser (CoreDataGeneratedAccessors)

- (void)addComments:(NSSet*)value_;
- (void)removeComments:(NSSet*)value_;
- (void)addCommentsObject:(MRSLComment*)value_;
- (void)removeCommentsObject:(MRSLComment*)value_;

- (void)addMorsels:(NSSet*)value_;
- (void)removeMorsels:(NSSet*)value_;
- (void)addMorselsObject:(MRSLMorsel*)value_;
- (void)removeMorselsObject:(MRSLMorsel*)value_;

- (void)addTags:(NSSet*)value_;
- (void)removeTags:(NSSet*)value_;
- (void)addTagsObject:(MRSLTag*)value_;
- (void)removeTagsObject:(MRSLTag*)value_;

@end

@interface _MRSLUser (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveAuth_token;
- (void)setPrimitiveAuth_token:(NSString*)value;




- (NSString*)primitiveBio;
- (void)setPrimitiveBio:(NSString*)value;




- (NSDate*)primitiveCreationDate;
- (void)setPrimitiveCreationDate:(NSDate*)value;




- (NSDate*)primitiveDateFollowed;
- (void)setPrimitiveDateFollowed:(NSDate*)value;




- (NSNumber*)primitiveDraft_count;
- (void)setPrimitiveDraft_count:(NSNumber*)value;

- (int32_t)primitiveDraft_countValue;
- (void)setPrimitiveDraft_countValue:(int32_t)value_;




- (NSString*)primitiveEmail;
- (void)setPrimitiveEmail:(NSString*)value;




- (NSString*)primitiveFacebook_uid;
- (void)setPrimitiveFacebook_uid:(NSString*)value;




- (NSString*)primitiveFirst_name;
- (void)setPrimitiveFirst_name:(NSString*)value;




- (NSNumber*)primitiveFollowed_users_count;
- (void)setPrimitiveFollowed_users_count:(NSNumber*)value;

- (int32_t)primitiveFollowed_users_countValue;
- (void)setPrimitiveFollowed_users_countValue:(int32_t)value_;




- (NSNumber*)primitiveFollower_count;
- (void)setPrimitiveFollower_count:(NSNumber*)value;

- (int32_t)primitiveFollower_countValue;
- (void)setPrimitiveFollower_countValue:(int32_t)value_;




- (NSNumber*)primitiveFollowing;
- (void)setPrimitiveFollowing:(NSNumber*)value;

- (BOOL)primitiveFollowingValue;
- (void)setPrimitiveFollowingValue:(BOOL)value_;




- (NSString*)primitiveIndustry;
- (void)setPrimitiveIndustry:(NSString*)value;




- (NSString*)primitiveLast_name;
- (void)setPrimitiveLast_name:(NSString*)value;




- (NSNumber*)primitiveLiked_items_count;
- (void)setPrimitiveLiked_items_count:(NSNumber*)value;

- (int32_t)primitiveLiked_items_countValue;
- (void)setPrimitiveLiked_items_countValue:(int32_t)value_;




- (NSNumber*)primitiveMorsel_count;
- (void)setPrimitiveMorsel_count:(NSNumber*)value;

- (int32_t)primitiveMorsel_countValue;
- (void)setPrimitiveMorsel_countValue:(int32_t)value_;




- (NSData*)primitiveProfilePhotoFull;
- (void)setPrimitiveProfilePhotoFull:(NSData*)value;




- (NSData*)primitiveProfilePhotoLarge;
- (void)setPrimitiveProfilePhotoLarge:(NSData*)value;




- (NSData*)primitiveProfilePhotoThumb;
- (void)setPrimitiveProfilePhotoThumb:(NSData*)value;




- (NSString*)primitiveProfilePhotoURL;
- (void)setPrimitiveProfilePhotoURL:(NSString*)value;




- (NSNumber*)primitiveStaff;
- (void)setPrimitiveStaff:(NSNumber*)value;

- (BOOL)primitiveStaffValue;
- (void)setPrimitiveStaffValue:(BOOL)value_;




- (NSString*)primitiveTwitter_username;
- (void)setPrimitiveTwitter_username:(NSString*)value;




- (NSNumber*)primitiveUserID;
- (void)setPrimitiveUserID:(NSNumber*)value;

- (int32_t)primitiveUserIDValue;
- (void)setPrimitiveUserIDValue:(int32_t)value_;




- (NSString*)primitiveUsername;
- (void)setPrimitiveUsername:(NSString*)value;





- (MRSLActivity*)primitiveActivities;
- (void)setPrimitiveActivities:(MRSLActivity*)value;



- (NSMutableSet*)primitiveComments;
- (void)setPrimitiveComments:(NSMutableSet*)value;



- (NSMutableSet*)primitiveMorsels;
- (void)setPrimitiveMorsels:(NSMutableSet*)value;



- (NSMutableSet*)primitiveTags;
- (void)setPrimitiveTags:(NSMutableSet*)value;


@end
