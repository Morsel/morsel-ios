#import "MRSLComment.h"

#import "ModelController.h"

#import "MRSLMorsel.h"
#import "MRSLUser.h"

@interface MRSLComment ()

@end

@implementation MRSLComment

- (void)setWithDictionary:(NSDictionary *)dictionary {
    if (![dictionary[@"created_at"] isEqual:[NSNull null]]) {
        NSString *dateString = dictionary[@"created_at"];
        self.creationDate = [[ModelController sharedController].defaultDateFormatter dateFromString:dateString];
    }
    self.commentID = ([dictionary[@"id"] isEqual:[NSNull null]]) ? self.commentID : [NSNumber numberWithInt:[dictionary[@"id"] intValue]];
    self.text = ([dictionary[@"description"] isEqual:[NSNull null]]) ? self.text : dictionary[@"description"];
    
    if (![dictionary[@"morsel_id"] isEqual:[NSNull null]]) {
        NSNumber *morselID = dictionary[@"morsel_id"];
        MRSLMorsel *morsel = [MRSLMorsel MR_findFirstByAttribute:MRSLMorselAttributes.morselID
                                                       withValue:morselID];
        if (morsel) self.morsel = morsel;
    }
    
    if (![dictionary[@"creator_id"] isEqual:[NSNull null]]) {
        NSNumber *userID = dictionary[@"creator_id"];
        MRSLUser *user = [MRSLUser MR_findFirstByAttribute:MRSLUserAttributes.userID
                                                 withValue:userID];
        if (user) {
            self.user = user;
        } else {
            user = [MRSLUser MR_createInContext:[ModelController sharedController].defaultContext];
            user.userID = userID;
            [[ModelController sharedController].morselApiService getUserProfile:user
                                                                        success:nil
                                                                        failure:nil];
        }
    }
}

@end
