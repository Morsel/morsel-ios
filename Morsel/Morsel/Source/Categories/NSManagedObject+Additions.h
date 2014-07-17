//
//  NSManagedObject+Additions.h
//  Morsel
//
//  Created by Javier Otero on 2/6/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (Additions)

+ (NSString *)API_identifier;

- (NSString *)jsonKeyName;

- (NSDictionary *)objectToJSON;

@end
