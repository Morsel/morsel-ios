#import "_MRSLItem.h"

#import "MRSLImageRequestable.h"
#import "MRSLReportable.h"

@interface MRSLItem : _MRSLItem <MRSLImageRequestable, MRSLReportable>

+ (MRSLItem *)localUniqueItemInContext:(NSManagedObjectContext *)context;

- (BOOL)isCoverItem;
- (BOOL)isTemplatePlaceholderItem;

- (CGFloat)descriptionHeight;

- (NSURLRequest *)imageURLRequestForImageSizeType:(MRSLImageSizeType)type;

- (NSString *)socialMessage;

- (NSString *)displayName;

- (void)API_updateImage;

@end
