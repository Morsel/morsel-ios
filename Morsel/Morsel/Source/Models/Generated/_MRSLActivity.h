// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MRSLActivity.h instead.

#import <CoreData/CoreData.h>


extern const struct MRSLActivityAttributes {
	__unsafe_unretained NSString *actionType;
	__unsafe_unretained NSString *activityID;
	__unsafe_unretained NSString *creationDate;
	__unsafe_unretained NSString *subjectID;
	__unsafe_unretained NSString *subjectType;
} MRSLActivityAttributes;

extern const struct MRSLActivityRelationships {
	__unsafe_unretained NSString *creator;
	__unsafe_unretained NSString *item;
	__unsafe_unretained NSString *notification;
} MRSLActivityRelationships;

extern const struct MRSLActivityFetchedProperties {
} MRSLActivityFetchedProperties;

@class MRSLUser;
@class MRSLItem;
@class MRSLNotification;







@interface MRSLActivityID : NSManagedObjectID {}
@end

@interface _MRSLActivity : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MRSLActivityID*)objectID;





@property (nonatomic, strong) NSString* actionType;



//- (BOOL)validateActionType:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* activityID;



@property int32_t activityIDValue;
- (int32_t)activityIDValue;
- (void)setActivityIDValue:(int32_t)value_;

//- (BOOL)validateActivityID:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* creationDate;



//- (BOOL)validateCreationDate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* subjectID;



@property int32_t subjectIDValue;
- (int32_t)subjectIDValue;
- (void)setSubjectIDValue:(int32_t)value_;

//- (BOOL)validateSubjectID:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* subjectType;



//- (BOOL)validateSubjectType:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) MRSLUser *creator;

//- (BOOL)validateCreator:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) MRSLItem *item;

//- (BOOL)validateItem:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) MRSLNotification *notification;

//- (BOOL)validateNotification:(id*)value_ error:(NSError**)error_;





@end

@interface _MRSLActivity (CoreDataGeneratedAccessors)

@end

@interface _MRSLActivity (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveActionType;
- (void)setPrimitiveActionType:(NSString*)value;




- (NSNumber*)primitiveActivityID;
- (void)setPrimitiveActivityID:(NSNumber*)value;

- (int32_t)primitiveActivityIDValue;
- (void)setPrimitiveActivityIDValue:(int32_t)value_;




- (NSDate*)primitiveCreationDate;
- (void)setPrimitiveCreationDate:(NSDate*)value;




- (NSNumber*)primitiveSubjectID;
- (void)setPrimitiveSubjectID:(NSNumber*)value;

- (int32_t)primitiveSubjectIDValue;
- (void)setPrimitiveSubjectIDValue:(int32_t)value_;




- (NSString*)primitiveSubjectType;
- (void)setPrimitiveSubjectType:(NSString*)value;





- (MRSLUser*)primitiveCreator;
- (void)setPrimitiveCreator:(MRSLUser*)value;



- (MRSLItem*)primitiveItem;
- (void)setPrimitiveItem:(MRSLItem*)value;



- (MRSLNotification*)primitiveNotification;
- (void)setPrimitiveNotification:(MRSLNotification*)value;


@end
