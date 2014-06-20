// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MRSLUser.h instead.

#import <CoreData/CoreData.h>


extern const struct MRSLUserAttributes {
	__unsafe_unretained NSString *auth_token;
	__unsafe_unretained NSString *auto_follow;
	__unsafe_unretained NSString *bio;
	__unsafe_unretained NSString *creationDate;
	__unsafe_unretained NSString *dateFollowed;
	__unsafe_unretained NSString *draft_count;
	__unsafe_unretained NSString *email;
	__unsafe_unretained NSString *facebook_uid;
	__unsafe_unretained NSString *first_name;
	__unsafe_unretained NSString *followed_user_count;
	__unsafe_unretained NSString *follower_count;
	__unsafe_unretained NSString *following;
	__unsafe_unretained NSString *industryType;
	__unsafe_unretained NSString *last_name;
	__unsafe_unretained NSString *liked_item_count;
	__unsafe_unretained NSString *morsel_count;
	__unsafe_unretained NSString *profilePhotoFull;
	__unsafe_unretained NSString *profilePhotoLarge;
	__unsafe_unretained NSString *profilePhotoThumb;
	__unsafe_unretained NSString *profilePhotoURL;
	__unsafe_unretained NSString *staff;
	__unsafe_unretained NSString *title;
	__unsafe_unretained NSString *twitter_username;
	__unsafe_unretained NSString *userID;
	__unsafe_unretained NSString *username;
} MRSLUserAttributes;

extern const struct MRSLUserRelationships {
	__unsafe_unretained NSString *activities;
	__unsafe_unretained NSString *activitiesAsSubject;
	__unsafe_unretained NSString *comments;
	__unsafe_unretained NSString *morsels;
	__unsafe_unretained NSString *places;
	__unsafe_unretained NSString *tags;
} MRSLUserRelationships;

extern const struct MRSLUserFetchedProperties {
} MRSLUserFetchedProperties;

@class MRSLActivity;
@class MRSLActivity;
@class MRSLComment;
@class MRSLMorsel;
@class MRSLPlace;
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





@property (nonatomic, strong) NSNumber* auto_follow;



@property BOOL auto_followValue;
- (BOOL)auto_followValue;
- (void)setAuto_followValue:(BOOL)value_;

//- (BOOL)validateAuto_follow:(id*)value_ error:(NSError**)error_;





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





@property (nonatomic, strong) NSNumber* followed_user_count;



@property int32_t followed_user_countValue;
- (int32_t)followed_user_countValue;
- (void)setFollowed_user_countValue:(int32_t)value_;

//- (BOOL)validateFollowed_user_count:(id*)value_ error:(NSError**)error_;





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





@property (nonatomic, strong) NSNumber* industryType;



@property int16_t industryTypeValue;
- (int16_t)industryTypeValue;
- (void)setIndustryTypeValue:(int16_t)value_;

//- (BOOL)validateIndustryType:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* last_name;



//- (BOOL)validateLast_name:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* liked_item_count;



@property int32_t liked_item_countValue;
- (int32_t)liked_item_countValue;
- (void)setLiked_item_countValue:(int32_t)value_;

//- (BOOL)validateLiked_item_count:(id*)value_ error:(NSError**)error_;





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





@property (nonatomic, strong) NSString* title;



//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* twitter_username;



//- (BOOL)validateTwitter_username:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* userID;



@property int32_t userIDValue;
- (int32_t)userIDValue;
- (void)setUserIDValue:(int32_t)value_;

//- (BOOL)validateUserID:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* username;



//- (BOOL)validateUsername:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *activities;

- (NSMutableSet*)activitiesSet;




@property (nonatomic, strong) NSSet *activitiesAsSubject;

- (NSMutableSet*)activitiesAsSubjectSet;




@property (nonatomic, strong) NSSet *comments;

- (NSMutableSet*)commentsSet;




@property (nonatomic, strong) NSSet *morsels;

- (NSMutableSet*)morselsSet;




@property (nonatomic, strong) NSSet *places;

- (NSMutableSet*)placesSet;




@property (nonatomic, strong) NSSet *tags;

- (NSMutableSet*)tagsSet;





@end

@interface _MRSLUser (CoreDataGeneratedAccessors)

- (void)addActivities:(NSSet*)value_;
- (void)removeActivities:(NSSet*)value_;
- (void)addActivitiesObject:(MRSLActivity*)value_;
- (void)removeActivitiesObject:(MRSLActivity*)value_;

- (void)addActivitiesAsSubject:(NSSet*)value_;
- (void)removeActivitiesAsSubject:(NSSet*)value_;
- (void)addActivitiesAsSubjectObject:(MRSLActivity*)value_;
- (void)removeActivitiesAsSubjectObject:(MRSLActivity*)value_;

- (void)addComments:(NSSet*)value_;
- (void)removeComments:(NSSet*)value_;
- (void)addCommentsObject:(MRSLComment*)value_;
- (void)removeCommentsObject:(MRSLComment*)value_;

- (void)addMorsels:(NSSet*)value_;
- (void)removeMorsels:(NSSet*)value_;
- (void)addMorselsObject:(MRSLMorsel*)value_;
- (void)removeMorselsObject:(MRSLMorsel*)value_;

- (void)addPlaces:(NSSet*)value_;
- (void)removePlaces:(NSSet*)value_;
- (void)addPlacesObject:(MRSLPlace*)value_;
- (void)removePlacesObject:(MRSLPlace*)value_;

- (void)addTags:(NSSet*)value_;
- (void)removeTags:(NSSet*)value_;
- (void)addTagsObject:(MRSLTag*)value_;
- (void)removeTagsObject:(MRSLTag*)value_;

@end

@interface _MRSLUser (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveAuth_token;
- (void)setPrimitiveAuth_token:(NSString*)value;




- (NSNumber*)primitiveAuto_follow;
- (void)setPrimitiveAuto_follow:(NSNumber*)value;

- (BOOL)primitiveAuto_followValue;
- (void)setPrimitiveAuto_followValue:(BOOL)value_;




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




- (NSNumber*)primitiveFollowed_user_count;
- (void)setPrimitiveFollowed_user_count:(NSNumber*)value;

- (int32_t)primitiveFollowed_user_countValue;
- (void)setPrimitiveFollowed_user_countValue:(int32_t)value_;




- (NSNumber*)primitiveFollower_count;
- (void)setPrimitiveFollower_count:(NSNumber*)value;

- (int32_t)primitiveFollower_countValue;
- (void)setPrimitiveFollower_countValue:(int32_t)value_;




- (NSNumber*)primitiveFollowing;
- (void)setPrimitiveFollowing:(NSNumber*)value;

- (BOOL)primitiveFollowingValue;
- (void)setPrimitiveFollowingValue:(BOOL)value_;




- (NSNumber*)primitiveIndustryType;
- (void)setPrimitiveIndustryType:(NSNumber*)value;

- (int16_t)primitiveIndustryTypeValue;
- (void)setPrimitiveIndustryTypeValue:(int16_t)value_;




- (NSString*)primitiveLast_name;
- (void)setPrimitiveLast_name:(NSString*)value;




- (NSNumber*)primitiveLiked_item_count;
- (void)setPrimitiveLiked_item_count:(NSNumber*)value;

- (int32_t)primitiveLiked_item_countValue;
- (void)setPrimitiveLiked_item_countValue:(int32_t)value_;




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




- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;




- (NSString*)primitiveTwitter_username;
- (void)setPrimitiveTwitter_username:(NSString*)value;




- (NSNumber*)primitiveUserID;
- (void)setPrimitiveUserID:(NSNumber*)value;

- (int32_t)primitiveUserIDValue;
- (void)setPrimitiveUserIDValue:(int32_t)value_;




- (NSString*)primitiveUsername;
- (void)setPrimitiveUsername:(NSString*)value;





- (NSMutableSet*)primitiveActivities;
- (void)setPrimitiveActivities:(NSMutableSet*)value;



- (NSMutableSet*)primitiveActivitiesAsSubject;
- (void)setPrimitiveActivitiesAsSubject:(NSMutableSet*)value;



- (NSMutableSet*)primitiveComments;
- (void)setPrimitiveComments:(NSMutableSet*)value;



- (NSMutableSet*)primitiveMorsels;
- (void)setPrimitiveMorsels:(NSMutableSet*)value;



- (NSMutableSet*)primitivePlaces;
- (void)setPrimitivePlaces:(NSMutableSet*)value;



- (NSMutableSet*)primitiveTags;
- (void)setPrimitiveTags:(NSMutableSet*)value;


@end
