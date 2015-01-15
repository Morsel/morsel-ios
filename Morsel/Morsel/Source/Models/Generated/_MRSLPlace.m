// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MRSLPlace.m instead.

#import "_MRSLPlace.h"

const struct MRSLPlaceAttributes MRSLPlaceAttributes = {
	.address = @"address",
	.city = @"city",
	.country = @"country",
	.credit_cards = @"credit_cards",
	.days = @"days",
	.dining_options = @"dining_options",
	.dining_style = @"dining_style",
	.dress_code = @"dress_code",
	.facebook_page_id = @"facebook_page_id",
	.follower_count = @"follower_count",
	.following = @"following",
	.formatted_phone = @"formatted_phone",
	.foursquare_timeframes = @"foursquare_timeframes",
	.lat = @"lat",
	.lon = @"lon",
	.menu_mobile_url = @"menu_mobile_url",
	.menu_url = @"menu_url",
	.name = @"name",
	.outdoor_seating = @"outdoor_seating",
	.parking = @"parking",
	.parking_details = @"parking_details",
	.placeID = @"placeID",
	.postal_code = @"postal_code",
	.price_tier = @"price_tier",
	.public_transit = @"public_transit",
	.reservations = @"reservations",
	.reservations_url = @"reservations_url",
	.state = @"state",
	.title = @"title",
	.twitter_username = @"twitter_username",
	.website_url = @"website_url",
};

const struct MRSLPlaceRelationships MRSLPlaceRelationships = {
	.activitiesAsSubject = @"activitiesAsSubject",
	.collection = @"collection",
	.morsels = @"morsels",
	.users = @"users",
};

const struct MRSLPlaceFetchedProperties MRSLPlaceFetchedProperties = {
};

@implementation MRSLPlaceID
@end

@implementation _MRSLPlace

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"MRSLPlace" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"MRSLPlace";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"MRSLPlace" inManagedObjectContext:moc_];
}

- (MRSLPlaceID*)objectID {
	return (MRSLPlaceID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"follower_countValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"follower_count"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"followingValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"following"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"latValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"lat"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"lonValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"lon"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"placeIDValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"placeID"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"price_tierValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"price_tier"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic address;






@dynamic city;






@dynamic country;






@dynamic credit_cards;






@dynamic days;






@dynamic dining_options;






@dynamic dining_style;






@dynamic dress_code;






@dynamic facebook_page_id;






@dynamic follower_count;



- (int32_t)follower_countValue {
	NSNumber *result = [self follower_count];
	return [result intValue];
}

- (void)setFollower_countValue:(int32_t)value_ {
	[self setFollower_count:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveFollower_countValue {
	NSNumber *result = [self primitiveFollower_count];
	return [result intValue];
}

- (void)setPrimitiveFollower_countValue:(int32_t)value_ {
	[self setPrimitiveFollower_count:[NSNumber numberWithInt:value_]];
}





@dynamic following;



- (BOOL)followingValue {
	NSNumber *result = [self following];
	return [result boolValue];
}

- (void)setFollowingValue:(BOOL)value_ {
	[self setFollowing:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveFollowingValue {
	NSNumber *result = [self primitiveFollowing];
	return [result boolValue];
}

- (void)setPrimitiveFollowingValue:(BOOL)value_ {
	[self setPrimitiveFollowing:[NSNumber numberWithBool:value_]];
}





@dynamic formatted_phone;






@dynamic foursquare_timeframes;






@dynamic lat;



- (float)latValue {
	NSNumber *result = [self lat];
	return [result floatValue];
}

- (void)setLatValue:(float)value_ {
	[self setLat:[NSNumber numberWithFloat:value_]];
}

- (float)primitiveLatValue {
	NSNumber *result = [self primitiveLat];
	return [result floatValue];
}

- (void)setPrimitiveLatValue:(float)value_ {
	[self setPrimitiveLat:[NSNumber numberWithFloat:value_]];
}





@dynamic lon;



- (float)lonValue {
	NSNumber *result = [self lon];
	return [result floatValue];
}

- (void)setLonValue:(float)value_ {
	[self setLon:[NSNumber numberWithFloat:value_]];
}

- (float)primitiveLonValue {
	NSNumber *result = [self primitiveLon];
	return [result floatValue];
}

- (void)setPrimitiveLonValue:(float)value_ {
	[self setPrimitiveLon:[NSNumber numberWithFloat:value_]];
}





@dynamic menu_mobile_url;






@dynamic menu_url;






@dynamic name;






@dynamic outdoor_seating;






@dynamic parking;






@dynamic parking_details;






@dynamic placeID;



- (int32_t)placeIDValue {
	NSNumber *result = [self placeID];
	return [result intValue];
}

- (void)setPlaceIDValue:(int32_t)value_ {
	[self setPlaceID:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitivePlaceIDValue {
	NSNumber *result = [self primitivePlaceID];
	return [result intValue];
}

- (void)setPrimitivePlaceIDValue:(int32_t)value_ {
	[self setPrimitivePlaceID:[NSNumber numberWithInt:value_]];
}





@dynamic postal_code;






@dynamic price_tier;



- (int16_t)price_tierValue {
	NSNumber *result = [self price_tier];
	return [result shortValue];
}

- (void)setPrice_tierValue:(int16_t)value_ {
	[self setPrice_tier:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitivePrice_tierValue {
	NSNumber *result = [self primitivePrice_tier];
	return [result shortValue];
}

- (void)setPrimitivePrice_tierValue:(int16_t)value_ {
	[self setPrimitivePrice_tier:[NSNumber numberWithShort:value_]];
}





@dynamic public_transit;






@dynamic reservations;






@dynamic reservations_url;






@dynamic state;






@dynamic title;






@dynamic twitter_username;






@dynamic website_url;






@dynamic activitiesAsSubject;

	
- (NSMutableSet*)activitiesAsSubjectSet {
	[self willAccessValueForKey:@"activitiesAsSubject"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"activitiesAsSubject"];
  
	[self didAccessValueForKey:@"activitiesAsSubject"];
	return result;
}
	

@dynamic collection;

	
- (NSMutableSet*)collectionSet {
	[self willAccessValueForKey:@"collection"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"collection"];
  
	[self didAccessValueForKey:@"collection"];
	return result;
}
	

@dynamic morsels;

	
- (NSMutableSet*)morselsSet {
	[self willAccessValueForKey:@"morsels"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"morsels"];
  
	[self didAccessValueForKey:@"morsels"];
	return result;
}
	

@dynamic users;

	
- (NSMutableSet*)usersSet {
	[self willAccessValueForKey:@"users"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"users"];
  
	[self didAccessValueForKey:@"users"];
	return result;
}
	






@end
