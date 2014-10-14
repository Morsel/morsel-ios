#import "_MRSLActivity.h"

@interface MRSLActivity : _MRSLActivity

- (BOOL)hasItemSubject;
- (BOOL)hasMorselSubject;
- (BOOL)hasPlaceSubject;
- (BOOL)hasUserSubject;

- (BOOL)isCommentAction;
- (BOOL)isFollowAction;
- (BOOL)isLikeAction;
- (BOOL)isMorselUserTagAction;

- (NSString *)message;

@end
