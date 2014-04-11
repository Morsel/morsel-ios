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
	__unsafe_unretained NSString *item_count;
	__unsafe_unretained NSString *last_name;
	__unsafe_unretained NSString *like_count;
	__unsafe_unretained NSString *profilePhotoFull;
	__unsafe_unretained NSString *profilePhotoLarge;
	__unsafe_unretained NSString *profilePhotoThumb;
	__unsafe_unretained NSString *profilePhotoURL;
	__unsafe_unretained NSString *title;
	__unsafe_unretained NSString *twitter_username;
	__unsafe_unretained NSString *userID;
	__unsafe_unretained NSString *username;
} MRSLUserAttributes;

extern const struct MRSLUserRelationships {
	__unsafe_unretained NSString *activities;
	__unsafe_unretained NSString *comments;
	__unsafe_unretained NSString *morsels;
} MRSLUserRelationships;

extern const struct MRSLUserFetchedProperties {
} MRSLUserFetchedProperties;

@class MRSLActivity;
@class MRSLComment;
@class MRSLMorsel;




















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





@property (nonatomic, strong) NSNumber* item_count;



@property int32_t item_countValue;
- (int32_t)item_countValue;
- (void)setItem_countValue:(int32_t)value_;

//- (BOOL)validateItem_count:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* last_name;



//- (BOOL)validateLast_name:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* like_count;



@property int32_t like_countValue;
- (int32_t)like_countValue;
- (void)setLike_countValue:(int32_t)value_;

//- (BOOL)validateLike_count:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSData* profilePhotoFull;



//- (BOOL)validateProfilePhotoFull:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSData* profilePhotoLarge;



//- (BOOL)validateProfilePhotoLarge:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSData* profilePhotoThumb;



//- (BOOL)validateProfilePhotoThumb:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* profilePhotoURL;



//- (BOOL)validateProfilePhotoURL:(id*)value_ error:(NSError**)error_;





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





@property (nonatomic, strong) MRSLActivity *activities;

//- (BOOL)validateActivities:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSSet *comments;

- (NSMutableSet*)commentsSet;




@property (nonatomic, strong) NSSet *morsels;

- (NSMutableSet*)morselsSet;





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

- (int32_t)primitiveDraft_countValue;
- (void)setPrimitiveDraft_countValue:(int32_t)value_;




- (NSString*)primitiveEmail;
- (void)setPrimitiveEmail:(NSString*)value;




- (NSString*)primitiveFacebook_uid;
- (void)setPrimitiveFacebook_uid:(NSString*)value;




- (NSString*)primitiveFirst_name;
- (void)setPrimitiveFirst_name:(NSString*)value;




- (NSNumber*)primitiveItem_count;
- (void)setPrimitiveItem_count:(NSNumber*)value;

- (int32_t)primitiveItem_countValue;
- (void)setPrimitiveItem_countValue:(int32_t)value_;




- (NSString*)primitiveLast_name;
- (void)setPrimitiveLast_name:(NSString*)value;




- (NSNumber*)primitiveLike_count;
- (void)setPrimitiveLike_count:(NSNumber*)value;

- (int32_t)primitiveLike_countValue;
- (void)setPrimitiveLike_countValue:(int32_t)value_;




- (NSData*)primitiveProfilePhotoFull;
- (void)setPrimitiveProfilePhotoFull:(NSData*)value;




- (NSData*)primitiveProfilePhotoLarge;
- (void)setPrimitiveProfilePhotoLarge:(NSData*)value;




- (NSData*)primitiveProfilePhotoThumb;
- (void)setPrimitiveProfilePhotoThumb:(NSData*)value;




- (NSString*)primitiveProfilePhotoURL;
- (void)setPrimitiveProfilePhotoURL:(NSString*)value;




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





- (MRSLActivity*)primitiveActivities;
- (void)setPrimitiveActivities:(MRSLActivity*)value;



- (NSMutableSet*)primitiveComments;
- (void)setPrimitiveComments:(NSMutableSet*)value;



- (NSMutableSet*)primitiveMorsels;
- (void)setPrimitiveMorsels:(NSMutableSet*)value;


@end
