#import "MRSLMorsel.h"

#import "MRSLAPIService+Morsel.h"
#import "MRSLAPIService+Report.h"
#import "MRSLAPIService+Templates.h"

#import "MRSLItem.h"
#import "MRSLPlace.h"
#import "MRSLTemplate.h"
#import "MRSLTemplateItem.h"
#import "MRSLUser.h"

@implementation MRSLMorsel

#pragma mark - Additions

+ (NSString *)API_identifier {
    return MRSLMorselAttributes.morselID;
}

- (NSString *)jsonKeyName {
    return @"morsel";
}

- (NSDictionary *)objectToJSON {
    NSMutableDictionary *objectInfoJSON = [NSMutableDictionary dictionary];
    objectInfoJSON[@"title"] = NSNullIfNil(self.title);
    objectInfoJSON[@"place_id"] = NSNullIfNil(self.place.placeID);
    if (self.template_id) objectInfoJSON[@"template_id"] = NSNullIfNil(self.template_id);
    MRSLItem *coverItem = [self coverItem];
    if (coverItem) objectInfoJSON[@"primary_item_id"] = NSNullIfNil(coverItem.itemID);

    return objectInfoJSON;
}

#pragma mark - Instance Methods

- (BOOL)hasCreatorInfo {
    //  Can tell if a User object has been fetched if a username exists.
    return self.creator && self.creator.username;
}

- (BOOL)hasPlaceholderTitle {
    return (([self.title length] == 0 || !self.title) && self.template_id);
}

- (BOOL)hasTaggedUsers {
    return self.tagged_users_countValue > 0;
}

- (CGFloat)coverInformationHeight {
    CGFloat coverInfoHeight = 0.f;

    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    CGRect coverTitleRect =[self.title boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - (MRSLCellDefaultPadding * 2), CGFLOAT_MAX)
                             options:NSStringDrawingUsesLineFragmentOrigin
                          attributes:@{NSFontAttributeName: [UIFont robotoSlabBoldFontOfSize:24.f],
                                       NSParagraphStyleAttributeName: paragraphStyle}
                             context:nil];

    NSMutableAttributedString *coverAttributedInfo = [self coverInformationFromProperties];
    if ([self hasTaggedUsers]) {
        NSMutableAttributedString *taggedAttributedString = [[NSMutableAttributedString alloc] initWithString:@"\n\nwith "
                                                                                                   attributes:@{NSFontAttributeName : [UIFont preferredRobotoFontForTextStyle:UIFontTextStyleCaption1]}];
        [coverAttributedInfo appendAttributedString:taggedAttributedString];
    }
    CGRect coverInfoRect = [coverAttributedInfo boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - (MRSLCellDefaultPadding * 2), CGFLOAT_MAX)
                                                             options:NSStringDrawingUsesLineFragmentOrigin
                                                             context:nil];
    coverInfoHeight = coverInfoRect.size.height + coverTitleRect.size.height + MRSLCellDefaultCoverPadding;
    return MAX(75.f, coverInfoHeight);
}

- (NSInteger)indexOfItem:(MRSLItem *)item {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemID == %@", item.itemID];
    NSArray *filteredArray = [[self itemsArray] filteredArrayUsingPredicate:predicate];
    id firstFoundObject = nil;
    firstFoundObject =  filteredArray.count > 0 ? filteredArray.firstObject : nil;
    return (firstFoundObject) ? [self.itemsArray indexOfObject:firstFoundObject] : 0;
}

- (NSDate *)latestUpdatedDate {
    __block NSDate *latestUpdated = self.lastUpdatedDate;

    [self.items enumerateObjectsUsingBlock:^(MRSLItem *item, BOOL *stop) {
        NSDate *itemUpdatedDate = [latestUpdated laterDate:item.lastUpdatedDate];

        if (![itemUpdatedDate isEqualToDate:latestUpdated]) {
            latestUpdated = item.lastUpdatedDate;
        }
    }];
    return latestUpdated;
}

- (NSArray *)itemsArray {
    NSSortDescriptor *idSort = [NSSortDescriptor sortDescriptorWithKey:@"sort_order"
                                                             ascending:YES];
    return [[self.items allObjects] sortedArrayUsingDescriptors:@[idSort]];
}

- (NSString *)placeholderTitle {
    MRSLTemplate *morselTemplate = [MRSLTemplate MR_findFirstByAttribute:MRSLTemplateAttributes.templateID
                                                               withValue:self.template_id];
    return [NSString stringWithFormat:@"%@ morsel", morselTemplate.title];
}

- (NSString *)firstItemDescription {
    return [self.itemsArray.firstObject itemDescription];
}

- (MRSLItem *)coverItem {
    MRSLItem *item = [MRSLItem MR_findFirstByAttribute:MRSLItemAttributes.itemID
                                             withValue:self.primary_item_id] ?: [self.itemsArray lastObject];
    return item;
}


- (NSData *)downloadCoverPhotoIfNilWithCompletion:(MRSLSuccessOrFailureBlock)completionOrNil {
    // Specifically to ensure the cover photo full NSData is available for Instagram distribution
    MRSLItem *coverItem = [self coverItem];
    if (coverItem.itemPhotoFull) return coverItem.itemPhotoFull;

    if (!coverItem.itemPhotoFull && coverItem.itemPhotoURL && !coverItem.photo_processingValue) {
        __block NSManagedObjectContext *workContext = nil;
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            workContext = localContext;
            MRSLItem *localContextCoverItem = [MRSLItem MR_findFirstByAttribute:MRSLItemAttributes.itemID
                                                                      withValue:coverItem.itemID
                                                                      inContext:localContext];
            localContextCoverItem.itemPhotoFull = [NSData dataWithContentsOfURL:[coverItem imageURLRequestForImageSizeType:MRSLImageSizeTypeFull].URL];
        } completion:^(BOOL success, NSError *error) {
            [workContext reset];
            if (completionOrNil) completionOrNil(success, error);
        }];
    } else if(completionOrNil) {
        completionOrNil(NO, nil);
    }

    return nil;
}

- (NSMutableAttributedString *)coverInformationFromProperties {
    NSString *fullName = [self.creator fullName];
    NSMutableAttributedString *infoAttributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"by %@", fullName]
                                                                                             attributes:@{NSFontAttributeName : [UIFont preferredRobotoFontForTextStyle:UIFontTextStyleCaption1]}];
    [infoAttributedString addAttribute:NSLinkAttributeName
                                 value:@"profile://display"
                                 range:[[infoAttributedString string] rangeOfString:fullName]];
    [infoAttributedString addAttribute:NSFontAttributeName
                                 value:[UIFont preferredRobotoFontForTextStyle:UIFontTextStyleHeadline]
                                 range:[[infoAttributedString string] rangeOfString:fullName]];

    if (self.place) {
        NSString *placeName = self.place.name;
        NSMutableAttributedString *placeAttributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@ %@, %@", placeName, self.place.city ?: @"", self.place.state ?: @""]
                                                                                                  attributes:@{NSFontAttributeName : [UIFont preferredRobotoFontForTextStyle:UIFontTextStyleCaption1]}];
        [placeAttributedString addAttribute:NSLinkAttributeName
                                      value:@"place://display"
                                      range:[[placeAttributedString string] rangeOfString:placeName]];
        [placeAttributedString addAttribute:NSFontAttributeName
                                      value:[UIFont preferredRobotoFontForTextStyle:UIFontTextStyleSubheadline]
                                      range:[[placeAttributedString string] rangeOfString:placeName]];
        [infoAttributedString appendAttributedString:placeAttributedString];
    }

    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    [infoAttributedString addAttribute:NSParagraphStyleAttributeName
                                 value:paragraphStyle
                                 range:NSMakeRange(0, infoAttributedString.length)];
    return infoAttributedString;
}

- (void)getCoverInformation:(MRSLAttributedStringBlock)attributedStringBlock {
    NSMutableAttributedString *infoAttributedString = [self coverInformationFromProperties];
    if ([self hasTaggedUsers]) {
        __weak __typeof(self) weakSelf = self;
        [_appDelegate.apiService getTaggedUsersForMorsel:self
                                               withMaxID:nil
                                               orSinceID:nil
                                                andCount:nil
                                                 success:^(NSArray *responseArray) {
                                                     if (weakSelf) {
                                                         NSMutableAttributedString *taggedAttributedString = [[NSMutableAttributedString alloc] initWithString:@"\n\nwith "
                                                                                                                                                    attributes:@{NSFontAttributeName : [UIFont preferredRobotoFontForTextStyle:UIFontTextStyleCaption1]}];
                                                         int userEnumCount = 0;
                                                         for (id objectID in responseArray) {
                                                             MRSLUser *taggedUser = [MRSLUser MR_findFirstByAttribute:MRSLUserAttributes.userID
                                                                                                            withValue:objectID
                                                                                                            inContext:[NSManagedObjectContext MR_defaultContext]];
                                                             NSString *userFullName = taggedUser.fullName;
                                                             NSMutableAttributedString *taggedUserAttributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", userFullName]];
                                                             [taggedUserAttributedString addAttribute:NSLinkAttributeName
                                                                                                value:[NSString stringWithFormat:@"user://%i", taggedUser.userIDValue]
                                                                                                range:[[taggedUserAttributedString string] rangeOfString:userFullName]];
                                                             [taggedUserAttributedString addAttribute:NSFontAttributeName
                                                                                                value:[UIFont preferredRobotoFontForTextStyle:UIFontTextStyleSubheadline]
                                                                                                range:[[taggedUserAttributedString string] rangeOfString:userFullName]];

                                                             BOOL hasMore = ([responseArray count] - (userEnumCount + 1) > 0);
                                                             if (hasMore) {
                                                                 NSAttributedString *commaAttributedString = [[NSMutableAttributedString alloc] initWithString:@", "
                                                                                                                                                    attributes:@{NSFontAttributeName : [UIFont preferredRobotoFontForTextStyle:UIFontTextStyleCaption1]}];

                                                                 [taggedUserAttributedString appendAttributedString:commaAttributedString];
                                                             }

                                                             [taggedAttributedString appendAttributedString:taggedUserAttributedString];
                                                             userEnumCount++;
                                                             if (userEnumCount == 2) {
                                                                 if (hasMore) {
                                                                     NSString *moreString = [NSString stringWithFormat:@"%i more", (int)[responseArray count] - userEnumCount];
                                                                     NSMutableAttributedString *moreAttributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"and %@", moreString]
                                                                                                                                                              attributes:@{NSFontAttributeName : [UIFont preferredRobotoFontForTextStyle:UIFontTextStyleCaption1]}];
                                                                     [moreAttributedString addAttribute:NSLinkAttributeName
                                                                                                  value:@"more://display"
                                                                                                  range:[[moreAttributedString string] rangeOfString:moreString]];
                                                                     [moreAttributedString addAttribute:NSFontAttributeName
                                                                                                  value:[UIFont preferredRobotoFontForTextStyle:UIFontTextStyleSubheadline]
                                                                                                  range:[[moreAttributedString string] rangeOfString:moreString]];
                                                                     [taggedAttributedString appendAttributedString:moreAttributedString];
                                                                 }
                                                                 break;
                                                             }
                                                         }

                                                         NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
                                                         [paragraphStyle setAlignment:NSTextAlignmentCenter];
                                                         [paragraphStyle setLineSpacing:4.f];
                                                         [taggedAttributedString addAttribute:NSParagraphStyleAttributeName
                                                                                        value:paragraphStyle
                                                                                        range:NSMakeRange(0, taggedAttributedString.length)];

                                                         [infoAttributedString appendAttributedString:taggedAttributedString];

                                                         if (attributedStringBlock) attributedStringBlock(infoAttributedString, nil);
                                                     }
                                                 } failure:^(NSError *error) {
                                                     if (attributedStringBlock) attributedStringBlock(nil, error);
                                                 }];
    } else {
        if (attributedStringBlock) attributedStringBlock(infoAttributedString, nil);
    }
}

#pragma mark - Templates

- (void)reloadTemplateDataIfNecessaryWithSuccess:(MRSLSuccessBlock)successOrNil
                                         failure:(MRSLFailureBlock)failureOrNil {
    MRSLTemplate *morselTemplate = [MRSLTemplate MR_findFirstByAttribute:MRSLTemplateAttributes.templateID
                                                               withValue:self.template_id ?: @(1)];
    if (morselTemplate) {
        [self reloadPlaceholderItemsWithSuccess:successOrNil
                                        failure:failureOrNil];
    }
}

- (void)reloadPlaceholderItemsWithSuccess:(MRSLSuccessBlock)successOrNil
                                  failure:(MRSLFailureBlock)failureOrNil {
    __weak __typeof(self)weakSelf = self;
    MRSLMorsel *localContextMorsel = [MRSLMorsel MR_findFirstByAttribute:MRSLMorselAttributes.morselID
                                                               withValue:weakSelf.morselID];
    for (MRSLItem *item in localContextMorsel.items) {
        if (item.template_order && !item.placeholder_description) {
            MRSLTemplateItem *templateItem = [MRSLTemplateItem MR_findFirstByAttribute:MRSLTemplateItemAttributes.template_order
                                                                             withValue:item.template_order];
            item.placeholder_description = templateItem.placeholder_description;
            item.placeholder_photo_large = templateItem.placeholder_photo_large;
            item.placeholder_photo_small = templateItem.placeholder_photo_small;
        }
    }
    [self.managedObjectContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        if (successOrNil) successOrNil(success);
    }];
}

#pragma mark - Reportable

- (NSString *)reportableUrlString {
    return [NSString stringWithFormat:@"morsels/%i/report", self.morselIDValue];
}

- (void)API_reportWithSuccess:(MRSLSuccessBlock)successOrNil
                      failure:(MRSLFailureBlock)failureOrNil {
    [_appDelegate.apiService sendReportable:self
                                    success:successOrNil
                                    failure:failureOrNil];
}

#pragma mark - MagicalRecord

- (void)didImport:(id)data {
    if (![data[@"creator_id"] isEqual:[NSNull null]] &&
        !self.creator) {
        NSNumber *creatorID = data[@"creator_id"];
        MRSLUser *user = [MRSLUser MR_findFirstByAttribute:MRSLUserAttributes.userID
                                                 withValue:creatorID
                                                 inContext:self.managedObjectContext];
        if (!user) {
            user = [MRSLUser MR_createInContext:self.managedObjectContext];
            user.userID = data[@"creator_id"];
        }
        self.creator = user;
    }

    if (![data[@"created_at"] isEqual:[NSNull null]]) {
        NSString *dateString = data[@"created_at"];
        self.creationDate = [_appDelegate.defaultDateFormatter dateFromString:dateString];
    }

    if (![data[@"published_at"] isEqual:[NSNull null]]) {
        NSString *publishString = data[@"published_at"];
        self.publishedDate = [_appDelegate.defaultDateFormatter dateFromString:publishString];
    }
    
    if (![data[@"updated_at"] isEqual:[NSNull null]]) {
        NSString *updateString = data[@"updated_at"];
        self.lastUpdatedDate = [_appDelegate.defaultDateFormatter dateFromString:updateString];
    }
    if (![data[@"liked_at"] isEqual:[NSNull null]]) {
        NSString *dateString = data[@"liked_at"];
        self.likedDate = [_appDelegate.defaultDateFormatter dateFromString:dateString];
    }
    if (![data[@"photos"] isEqual:[NSNull null]]) {
        NSDictionary *photoDictionary = data[@"photos"];
        self.morselPhotoURL = photoDictionary[@"_800x600"];
    }
}

@end
