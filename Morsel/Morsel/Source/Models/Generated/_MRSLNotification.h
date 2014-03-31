// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MRSLNotification.h instead.

#import <CoreData/CoreData.h>


extern const struct MRSLNotificationAttributes {
	__unsafe_unretained NSString *creationDate;
	__unsafe_unretained NSString *message;
	__unsafe_unretained NSString *notificationID;
	__unsafe_unretained NSString *payloadID;
	__unsafe_unretained NSString *payloadType;
} MRSLNotificationAttributes;

extern const struct MRSLNotificationRelationships {
	__unsafe_unretained NSString *activity;
} MRSLNotificationRelationships;

extern const struct MRSLNotificationFetchedProperties {
} MRSLNotificationFetchedProperties;

@class MRSLActivity;







@interface MRSLNotificationID : NSManagedObjectID {}
@end

@interface _MRSLNotification : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MRSLNotificationID*)objectID;





@property (nonatomic, strong) NSDate* creationDate;



//- (BOOL)validateCreationDate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* message;



//- (BOOL)validateMessage:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* notificationID;



@property int32_t notificationIDValue;
- (int32_t)notificationIDValue;
- (void)setNotificationIDValue:(int32_t)value_;

//- (BOOL)validateNotificationID:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* payloadID;



@property int32_t payloadIDValue;
- (int32_t)payloadIDValue;
- (void)setPayloadIDValue:(int32_t)value_;

//- (BOOL)validatePayloadID:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* payloadType;



//- (BOOL)validatePayloadType:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) MRSLActivity *activity;

//- (BOOL)validateActivity:(id*)value_ error:(NSError**)error_;





@end

@interface _MRSLNotification (CoreDataGeneratedAccessors)

@end

@interface _MRSLNotification (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveCreationDate;
- (void)setPrimitiveCreationDate:(NSDate*)value;




- (NSString*)primitiveMessage;
- (void)setPrimitiveMessage:(NSString*)value;




- (NSNumber*)primitiveNotificationID;
- (void)setPrimitiveNotificationID:(NSNumber*)value;

- (int32_t)primitiveNotificationIDValue;
- (void)setPrimitiveNotificationIDValue:(int32_t)value_;




- (NSNumber*)primitivePayloadID;
- (void)setPrimitivePayloadID:(NSNumber*)value;

- (int32_t)primitivePayloadIDValue;
- (void)setPrimitivePayloadIDValue:(int32_t)value_;




- (NSString*)primitivePayloadType;
- (void)setPrimitivePayloadType:(NSString*)value;





- (MRSLActivity*)primitiveActivity;
- (void)setPrimitiveActivity:(MRSLActivity*)value;


@end
