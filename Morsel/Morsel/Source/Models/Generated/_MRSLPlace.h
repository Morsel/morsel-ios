// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MRSLPlace.h instead.

#import <CoreData/CoreData.h>


extern const struct MRSLPlaceAttributes {
	__unsafe_unretained NSString *address;
	__unsafe_unretained NSString *city;
	__unsafe_unretained NSString *country;
	__unsafe_unretained NSString *credit_cards;
	__unsafe_unretained NSString *days;
	__unsafe_unretained NSString *dining_options;
	__unsafe_unretained NSString *dining_style;
	__unsafe_unretained NSString *dress_code;
	__unsafe_unretained NSString *facebook_page_id;
	__unsafe_unretained NSString *follower_count;
	__unsafe_unretained NSString *following;
	__unsafe_unretained NSString *formatted_phone;
	__unsafe_unretained NSString *foursquare_timeframes;
	__unsafe_unretained NSString *lat;
	__unsafe_unretained NSString *lon;
	__unsafe_unretained NSString *menu_mobile_url;
	__unsafe_unretained NSString *menu_url;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *outdoor_seating;
	__unsafe_unretained NSString *parking;
	__unsafe_unretained NSString *parking_details;
	__unsafe_unretained NSString *placeID;
	__unsafe_unretained NSString *postal_code;
	__unsafe_unretained NSString *price_tier;
	__unsafe_unretained NSString *public_transit;
	__unsafe_unretained NSString *reservations;
	__unsafe_unretained NSString *reservations_url;
	__unsafe_unretained NSString *state;
	__unsafe_unretained NSString *title;
	__unsafe_unretained NSString *twitter_username;
	__unsafe_unretained NSString *website_url;
} MRSLPlaceAttributes;

extern const struct MRSLPlaceRelationships {
	__unsafe_unretained NSString *activitiesAsSubject;
	__unsafe_unretained NSString *collection;
	__unsafe_unretained NSString *morsels;
	__unsafe_unretained NSString *users;
} MRSLPlaceRelationships;

extern const struct MRSLPlaceFetchedProperties {
} MRSLPlaceFetchedProperties;

@class MRSLActivity;
@class MRSLCollection;
@class MRSLMorsel;
@class MRSLUser;













@class NSArray;



















@interface MRSLPlaceID : NSManagedObjectID {}
@end

@interface _MRSLPlace : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MRSLPlaceID*)objectID;





@property (nonatomic, strong) NSString* address;



//- (BOOL)validateAddress:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* city;



//- (BOOL)validateCity:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* country;



//- (BOOL)validateCountry:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* credit_cards;



//- (BOOL)validateCredit_cards:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* days;



//- (BOOL)validateDays:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* dining_options;



//- (BOOL)validateDining_options:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* dining_style;



//- (BOOL)validateDining_style:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* dress_code;



//- (BOOL)validateDress_code:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* facebook_page_id;



//- (BOOL)validateFacebook_page_id:(id*)value_ error:(NSError**)error_;





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





@property (nonatomic, strong) NSString* formatted_phone;



//- (BOOL)validateFormatted_phone:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSArray* foursquare_timeframes;



//- (BOOL)validateFoursquare_timeframes:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* lat;



@property float latValue;
- (float)latValue;
- (void)setLatValue:(float)value_;

//- (BOOL)validateLat:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* lon;



@property float lonValue;
- (float)lonValue;
- (void)setLonValue:(float)value_;

//- (BOOL)validateLon:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* menu_mobile_url;



//- (BOOL)validateMenu_mobile_url:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* menu_url;



//- (BOOL)validateMenu_url:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* outdoor_seating;



//- (BOOL)validateOutdoor_seating:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* parking;



//- (BOOL)validateParking:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* parking_details;



//- (BOOL)validateParking_details:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* placeID;



@property int32_t placeIDValue;
- (int32_t)placeIDValue;
- (void)setPlaceIDValue:(int32_t)value_;

//- (BOOL)validatePlaceID:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* postal_code;



//- (BOOL)validatePostal_code:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* price_tier;



@property int16_t price_tierValue;
- (int16_t)price_tierValue;
- (void)setPrice_tierValue:(int16_t)value_;

//- (BOOL)validatePrice_tier:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* public_transit;



//- (BOOL)validatePublic_transit:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* reservations;



//- (BOOL)validateReservations:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* reservations_url;



//- (BOOL)validateReservations_url:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* state;



//- (BOOL)validateState:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* title;



//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* twitter_username;



//- (BOOL)validateTwitter_username:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* website_url;



//- (BOOL)validateWebsite_url:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *activitiesAsSubject;

- (NSMutableSet*)activitiesAsSubjectSet;




@property (nonatomic, strong) NSSet *collection;

- (NSMutableSet*)collectionSet;




@property (nonatomic, strong) NSSet *morsels;

- (NSMutableSet*)morselsSet;




@property (nonatomic, strong) NSSet *users;

- (NSMutableSet*)usersSet;





@end

@interface _MRSLPlace (CoreDataGeneratedAccessors)

- (void)addActivitiesAsSubject:(NSSet*)value_;
- (void)removeActivitiesAsSubject:(NSSet*)value_;
- (void)addActivitiesAsSubjectObject:(MRSLActivity*)value_;
- (void)removeActivitiesAsSubjectObject:(MRSLActivity*)value_;

- (void)addCollection:(NSSet*)value_;
- (void)removeCollection:(NSSet*)value_;
- (void)addCollectionObject:(MRSLCollection*)value_;
- (void)removeCollectionObject:(MRSLCollection*)value_;

- (void)addMorsels:(NSSet*)value_;
- (void)removeMorsels:(NSSet*)value_;
- (void)addMorselsObject:(MRSLMorsel*)value_;
- (void)removeMorselsObject:(MRSLMorsel*)value_;

- (void)addUsers:(NSSet*)value_;
- (void)removeUsers:(NSSet*)value_;
- (void)addUsersObject:(MRSLUser*)value_;
- (void)removeUsersObject:(MRSLUser*)value_;

@end

@interface _MRSLPlace (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveAddress;
- (void)setPrimitiveAddress:(NSString*)value;




- (NSString*)primitiveCity;
- (void)setPrimitiveCity:(NSString*)value;




- (NSString*)primitiveCountry;
- (void)setPrimitiveCountry:(NSString*)value;




- (NSString*)primitiveCredit_cards;
- (void)setPrimitiveCredit_cards:(NSString*)value;




- (NSString*)primitiveDays;
- (void)setPrimitiveDays:(NSString*)value;




- (NSString*)primitiveDining_options;
- (void)setPrimitiveDining_options:(NSString*)value;




- (NSString*)primitiveDining_style;
- (void)setPrimitiveDining_style:(NSString*)value;




- (NSString*)primitiveDress_code;
- (void)setPrimitiveDress_code:(NSString*)value;




- (NSString*)primitiveFacebook_page_id;
- (void)setPrimitiveFacebook_page_id:(NSString*)value;




- (NSNumber*)primitiveFollower_count;
- (void)setPrimitiveFollower_count:(NSNumber*)value;

- (int32_t)primitiveFollower_countValue;
- (void)setPrimitiveFollower_countValue:(int32_t)value_;




- (NSNumber*)primitiveFollowing;
- (void)setPrimitiveFollowing:(NSNumber*)value;

- (BOOL)primitiveFollowingValue;
- (void)setPrimitiveFollowingValue:(BOOL)value_;




- (NSString*)primitiveFormatted_phone;
- (void)setPrimitiveFormatted_phone:(NSString*)value;




- (NSArray*)primitiveFoursquare_timeframes;
- (void)setPrimitiveFoursquare_timeframes:(NSArray*)value;




- (NSNumber*)primitiveLat;
- (void)setPrimitiveLat:(NSNumber*)value;

- (float)primitiveLatValue;
- (void)setPrimitiveLatValue:(float)value_;




- (NSNumber*)primitiveLon;
- (void)setPrimitiveLon:(NSNumber*)value;

- (float)primitiveLonValue;
- (void)setPrimitiveLonValue:(float)value_;




- (NSString*)primitiveMenu_mobile_url;
- (void)setPrimitiveMenu_mobile_url:(NSString*)value;




- (NSString*)primitiveMenu_url;
- (void)setPrimitiveMenu_url:(NSString*)value;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSString*)primitiveOutdoor_seating;
- (void)setPrimitiveOutdoor_seating:(NSString*)value;




- (NSString*)primitiveParking;
- (void)setPrimitiveParking:(NSString*)value;




- (NSString*)primitiveParking_details;
- (void)setPrimitiveParking_details:(NSString*)value;




- (NSNumber*)primitivePlaceID;
- (void)setPrimitivePlaceID:(NSNumber*)value;

- (int32_t)primitivePlaceIDValue;
- (void)setPrimitivePlaceIDValue:(int32_t)value_;




- (NSString*)primitivePostal_code;
- (void)setPrimitivePostal_code:(NSString*)value;




- (NSNumber*)primitivePrice_tier;
- (void)setPrimitivePrice_tier:(NSNumber*)value;

- (int16_t)primitivePrice_tierValue;
- (void)setPrimitivePrice_tierValue:(int16_t)value_;




- (NSString*)primitivePublic_transit;
- (void)setPrimitivePublic_transit:(NSString*)value;




- (NSString*)primitiveReservations;
- (void)setPrimitiveReservations:(NSString*)value;




- (NSString*)primitiveReservations_url;
- (void)setPrimitiveReservations_url:(NSString*)value;




- (NSString*)primitiveState;
- (void)setPrimitiveState:(NSString*)value;




- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;




- (NSString*)primitiveTwitter_username;
- (void)setPrimitiveTwitter_username:(NSString*)value;




- (NSString*)primitiveWebsite_url;
- (void)setPrimitiveWebsite_url:(NSString*)value;





- (NSMutableSet*)primitiveActivitiesAsSubject;
- (void)setPrimitiveActivitiesAsSubject:(NSMutableSet*)value;



- (NSMutableSet*)primitiveCollection;
- (void)setPrimitiveCollection:(NSMutableSet*)value;



- (NSMutableSet*)primitiveMorsels;
- (void)setPrimitiveMorsels:(NSMutableSet*)value;



- (NSMutableSet*)primitiveUsers;
- (void)setPrimitiveUsers:(NSMutableSet*)value;


@end
