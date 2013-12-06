// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MRSLUser.h instead.

#import <CoreData/CoreData.h>


extern const struct MRSLUserAttributes {
	__unsafe_unretained NSString *emailAddress;
} MRSLUserAttributes;

extern const struct MRSLUserRelationships {
} MRSLUserRelationships;

extern const struct MRSLUserFetchedProperties {
} MRSLUserFetchedProperties;




@interface MRSLUserID : NSManagedObjectID {}
@end

@interface _MRSLUser : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MRSLUserID*)objectID;





@property (nonatomic, strong) NSString* emailAddress;



//- (BOOL)validateEmailAddress:(id*)value_ error:(NSError**)error_;






@end

@interface _MRSLUser (CoreDataGeneratedAccessors)

@end

@interface _MRSLUser (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveEmailAddress;
- (void)setPrimitiveEmailAddress:(NSString*)value;




@end
