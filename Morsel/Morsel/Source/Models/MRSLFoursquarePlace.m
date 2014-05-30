//
//  MRSLFoursquarePlace.m
//  Morsel
//
//  Created by Javier Otero on 5/29/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLFoursquarePlace.h"

@implementation MRSLFoursquarePlace

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        if (![dictionary[@"id"] isEqual:[NSNull null]]) {
            self.foursquarePlaceID = dictionary[@"id"];
        }
        if (![dictionary[@"name"] isEqual:[NSNull null]]) {
            self.name = dictionary[@"name"];
        }
        if (![dictionary[@"location"] isEqual:[NSNull null]]) {
            if (![dictionary[@"address"] isEqual:[NSNull null]]) {
                self.address = dictionary[@"location"][@"address"];
            }
            if (![dictionary[@"city"] isEqual:[NSNull null]]) {
                self.city = dictionary[@"location"][@"city"];
            }
            if (![dictionary[@"name"] isEqual:[NSNull null]]) {
                self.state = dictionary[@"location"][@"state"];
            }
        }
    }

    return self;
}

- (NSString *)cityState {
    return [NSString stringWithFormat:@"%@, %@", self.city, self.state];
}

- (NSString *)fullAddress {
    return [NSString stringWithFormat:@"%@\n%@, %@", self.address, self.city, self.state];
}

@end
