//
//  MRSLFoursquarePlace.h
//  Morsel
//
//  Created by Javier Otero on 5/29/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MRSLFoursquarePlace : NSObject

@property (strong, nonatomic) NSString *foursquarePlaceID;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *address;
@property (strong, nonatomic) NSString *city;
@property (strong, nonatomic) NSString *state;

- (id)initWithDictionary:(NSDictionary *)dictionary;

- (NSString *)cityState;
- (NSString *)fullAddress;

@end
