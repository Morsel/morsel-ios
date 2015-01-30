#import "MRSLCollection.h"

#import "MRSLAPIService+Place.h"
#import "MRSLAPIService+Profile.h"

#import "MRSLPlace.h"
#import "MRSLUser.h"

@interface MRSLCollection ()

@end


@implementation MRSLCollection

#pragma mark - Additions

+ (NSString *)API_identifier {
    return MRSLCollectionAttributes.collectionID;
}

- (NSString *)jsonKeyName {
    return @"collection";
}

- (NSDictionary *)objectToJSON {
    NSMutableDictionary *objectInfoJSON = [NSMutableDictionary dictionary];
    objectInfoJSON[@"title"] = NSNullIfNil((([self.title length] > 0) ? self.title : nil));
    objectInfoJSON[@"place_id"] = NSNullIfNil(self.place.placeID);
    objectInfoJSON[@"description"] = NSNullIfNil((([self.collectionDescription length] > 0) ? self.collectionDescription : nil));

    return objectInfoJSON;
}

#pragma mark - Instance Methods

- (NSArray *)morselsArray {
    NSSortDescriptor *idSort = [NSSortDescriptor sortDescriptorWithKey:@"sort_order"
                                                             ascending:NO];
    return [[self.morsels allObjects] sortedArrayUsingDescriptors:@[idSort]];
}

- (NSMutableAttributedString *)thumbnailInformation {
    NSMutableAttributedString *infoAttributedString = [[NSMutableAttributedString alloc] initWithString:self.title ?: @""
                                                                                             attributes:@{NSFontAttributeName : [UIFont preferredPrimaryFontForTextStyle:UIFontTextStyleHeadline],
                                                                                                          NSForegroundColorAttributeName: [UIColor whiteColor]}];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    [infoAttributedString addAttribute:NSParagraphStyleAttributeName
                                 value:paragraphStyle
                                 range:NSMakeRange(0, infoAttributedString.length)];

    return infoAttributedString;
}

- (CGFloat)descriptionHeight {
    if (!self.collectionDescription || [self.collectionDescription length] == 0) return 0.f;
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:self.collectionDescription
                                                                           attributes:@{NSFontAttributeName: [UIFont primaryLightFontOfSize:14.f]}];
    CGRect descriptionRect = [attributedString boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - (MRSLCellDefaultPadding * 2), CGFLOAT_MAX)
                                                            options:NSStringDrawingUsesLineFragmentOrigin
                                                            context:nil];
    return descriptionRect.size.height + (MRSLCellDefaultPadding * 2);
}

#pragma mark - MagicalRecord

- (void)didImport:(id)data {
    if (![data[@"user_id"] isEqual:[NSNull null]]) {
        NSNumber *userID = data[@"user_id"];
        MRSLUser *potentialUser = [MRSLUser MR_findFirstByAttribute:MRSLUserAttributes.userID
                                                          withValue:userID
                                                          inContext:self.managedObjectContext];
        if (potentialUser) {
            self.creator = potentialUser;
        } else {
            self.creator = [MRSLUser MR_createInContext:self.managedObjectContext];
            self.creator.userID = userID;
            [_appDelegate.apiService getUserProfile:self.creator
                                            success:nil
                                            failure:nil];
        }
    }

    if (![data[@"place_id"] isEqual:[NSNull null]]) {
        NSNumber *placeID = data[@"place_id"];
        MRSLPlace *potentialPlace = [MRSLPlace MR_findFirstByAttribute:MRSLPlaceAttributes.placeID
                                                             withValue:placeID
                                                             inContext:self.managedObjectContext];
        if (potentialPlace) {
            self.place = potentialPlace;
        } else {
            self.place = [MRSLPlace MR_createInContext:self.managedObjectContext];
            self.place.placeID = placeID;
            [_appDelegate.apiService getPlace:self.place
                                      success:nil
                                      failure:nil];
        }
    }

    if (![data[@"created_at"] isEqual:[NSNull null]]) {
        NSString *dateString = data[@"created_at"];
        self.creationDate = [_appDelegate.defaultDateFormatter dateFromString:dateString];
    }

    if (![data[@"updated_at"] isEqual:[NSNull null]]) {
        NSString *updateString = data[@"updated_at"];
        self.updatedDate = [_appDelegate.defaultDateFormatter dateFromString:updateString];
    }
}

@end
