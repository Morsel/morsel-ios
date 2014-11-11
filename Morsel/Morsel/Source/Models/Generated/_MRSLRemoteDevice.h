// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MRSLRemoteDevice.h instead.

#import <CoreData/CoreData.h>


extern const struct MRSLRemoteDeviceAttributes {
	__unsafe_unretained NSString *creationDate;
	__unsafe_unretained NSString *deviceID;
	__unsafe_unretained NSString *model;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *notify_item_comment;
	__unsafe_unretained NSString *notify_morsel_like;
	__unsafe_unretained NSString *notify_morsel_morsel_user_tag;
	__unsafe_unretained NSString *notify_user_follow;
	__unsafe_unretained NSString *token;
	__unsafe_unretained NSString *user_id;
} MRSLRemoteDeviceAttributes;

extern const struct MRSLRemoteDeviceRelationships {
} MRSLRemoteDeviceRelationships;

extern const struct MRSLRemoteDeviceFetchedProperties {
} MRSLRemoteDeviceFetchedProperties;













@interface MRSLRemoteDeviceID : NSManagedObjectID {}
@end

@interface _MRSLRemoteDevice : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MRSLRemoteDeviceID*)objectID;





@property (nonatomic, strong) NSDate* creationDate;



//- (BOOL)validateCreationDate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* deviceID;



@property int32_t deviceIDValue;
- (int32_t)deviceIDValue;
- (void)setDeviceIDValue:(int32_t)value_;

//- (BOOL)validateDeviceID:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* model;



//- (BOOL)validateModel:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* notify_item_comment;



@property BOOL notify_item_commentValue;
- (BOOL)notify_item_commentValue;
- (void)setNotify_item_commentValue:(BOOL)value_;

//- (BOOL)validateNotify_item_comment:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* notify_morsel_like;



@property BOOL notify_morsel_likeValue;
- (BOOL)notify_morsel_likeValue;
- (void)setNotify_morsel_likeValue:(BOOL)value_;

//- (BOOL)validateNotify_morsel_like:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* notify_morsel_morsel_user_tag;



@property BOOL notify_morsel_morsel_user_tagValue;
- (BOOL)notify_morsel_morsel_user_tagValue;
- (void)setNotify_morsel_morsel_user_tagValue:(BOOL)value_;

//- (BOOL)validateNotify_morsel_morsel_user_tag:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* notify_user_follow;



@property BOOL notify_user_followValue;
- (BOOL)notify_user_followValue;
- (void)setNotify_user_followValue:(BOOL)value_;

//- (BOOL)validateNotify_user_follow:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* token;



//- (BOOL)validateToken:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* user_id;



@property int32_t user_idValue;
- (int32_t)user_idValue;
- (void)setUser_idValue:(int32_t)value_;

//- (BOOL)validateUser_id:(id*)value_ error:(NSError**)error_;






@end

@interface _MRSLRemoteDevice (CoreDataGeneratedAccessors)

@end

@interface _MRSLRemoteDevice (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveCreationDate;
- (void)setPrimitiveCreationDate:(NSDate*)value;




- (NSNumber*)primitiveDeviceID;
- (void)setPrimitiveDeviceID:(NSNumber*)value;

- (int32_t)primitiveDeviceIDValue;
- (void)setPrimitiveDeviceIDValue:(int32_t)value_;




- (NSString*)primitiveModel;
- (void)setPrimitiveModel:(NSString*)value;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSNumber*)primitiveNotify_item_comment;
- (void)setPrimitiveNotify_item_comment:(NSNumber*)value;

- (BOOL)primitiveNotify_item_commentValue;
- (void)setPrimitiveNotify_item_commentValue:(BOOL)value_;




- (NSNumber*)primitiveNotify_morsel_like;
- (void)setPrimitiveNotify_morsel_like:(NSNumber*)value;

- (BOOL)primitiveNotify_morsel_likeValue;
- (void)setPrimitiveNotify_morsel_likeValue:(BOOL)value_;




- (NSNumber*)primitiveNotify_morsel_morsel_user_tag;
- (void)setPrimitiveNotify_morsel_morsel_user_tag:(NSNumber*)value;

- (BOOL)primitiveNotify_morsel_morsel_user_tagValue;
- (void)setPrimitiveNotify_morsel_morsel_user_tagValue:(BOOL)value_;




- (NSNumber*)primitiveNotify_user_follow;
- (void)setPrimitiveNotify_user_follow:(NSNumber*)value;

- (BOOL)primitiveNotify_user_followValue;
- (void)setPrimitiveNotify_user_followValue:(BOOL)value_;




- (NSString*)primitiveToken;
- (void)setPrimitiveToken:(NSString*)value;




- (NSNumber*)primitiveUser_id;
- (void)setPrimitiveUser_id:(NSNumber*)value;

- (int32_t)primitiveUser_idValue;
- (void)setPrimitiveUser_idValue:(int32_t)value_;




@end
