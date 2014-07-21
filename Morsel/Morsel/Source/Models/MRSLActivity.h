#import "_MRSLActivity.h"

@interface MRSLActivity : _MRSLActivity

- (BOOL)hasItemSubject;
- (BOOL)hasPlaceSubject;
- (BOOL)hasUserSubject;

- (BOOL)isCommentAction;
- (BOOL)isFollowAction;
- (BOOL)isLikeAction;

- (NSString *)message;

@end
