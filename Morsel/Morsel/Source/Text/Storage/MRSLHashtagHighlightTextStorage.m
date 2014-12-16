//
//  MRSLHashtagHighlightTextStorage.m
//  Morsel
//
//  Created by Javier Otero on 12/2/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLHashtagHighlightTextStorage.h"

@interface MRSLHashtagHighlightTextStorage () {
    NSMutableAttributedString *_backingStore;
}

@end

@implementation MRSLHashtagHighlightTextStorage

#pragma mark - Instance Methods

- (id)init {
    self = [super init];
    if (self) {
        _backingStore = [NSMutableAttributedString new];
    }
    return self;
}

#pragma mark - Action Methods

- (void)update {
    [self applyStylesToRange:NSMakeRange(0, self.length)];
}

#pragma mark - Mandatory Overrides

- (NSString *)string {
    return [_backingStore string];
}

- (NSDictionary *)attributesAtIndex:(NSUInteger)location
                     effectiveRange:(NSRangePointer)range {
    return [_backingStore attributesAtIndex:location
                             effectiveRange:range];
}

- (void)replaceCharactersInRange:(NSRange)range
                      withString:(NSString *)str {
    DDLogVerbose(@"replaceCharactersInRange:%@ withString:%@", NSStringFromRange(range), str);

    [self beginEditing];
    [_backingStore replaceCharactersInRange:range withString:str];
    [self edited:NSTextStorageEditedCharacters | NSTextStorageEditedAttributes
           range:range
  changeInLength:str.length - range.length];
    [self endEditing];
}

- (void)setAttributes:(NSDictionary *)attrs
                range:(NSRange)range {
    DDLogVerbose(@"setAttributes:%@ range:%@", attrs, NSStringFromRange(range));

    [self beginEditing];
    [_backingStore setAttributes:attrs range:range];
    [self edited:NSTextStorageEditedAttributes
           range:range
  changeInLength:0];
    [self endEditing];
}

#pragma mark - Hashtag Highlighting

- (void)processEditing {
    [self performReplacementsForRange:[self editedRange]];
    [super processEditing];
}

- (void)performReplacementsForRange:(NSRange)changedRange {
    NSRange extendedRange = NSUnionRange(changedRange, [[_backingStore string] lineRangeForRange:NSMakeRange(changedRange.location, 0)]);
    extendedRange = NSUnionRange(changedRange, [[_backingStore string] lineRangeForRange:NSMakeRange(NSMaxRange(changedRange), 0)]);
    [self applyStylesToRange:extendedRange];
}

- (void)applyStylesToRange:(NSRange)searchRange {
    // match hashtags
    NSString *regexStr = @"(?:\\s|^)(?:#|\\uFF03)([0-9a-z_]*[a-z_]+[a-z0-9_]*)";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexStr
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:nil];
    // iterate over each match, adding links
    [regex enumerateMatchesInString:[_backingStore string]
                            options:0
                              range:searchRange
                         usingBlock:^(NSTextCheckingResult *match,
                                      NSMatchingFlags flags,
                                      BOOL *stop){
                             NSRange adjustedRange = match.range;
                             adjustedRange.location += 2;
                             adjustedRange.length -= 2;
                             NSRange hashtagRange = match.range;
                             hashtagRange.location += 1;
                             hashtagRange.length -= 1;
                             NSString *linkString = [NSString stringWithFormat:@"hashtag://%@", [[self string] substringWithRange:adjustedRange]];
                             [self addAttribute:NSLinkAttributeName
                                          value:linkString
                                          range:hashtagRange];
                             [self addAttribute:NSFontAttributeName
                                          value:[UIFont preferredPrimaryFontForTextStyle:UIFontTextStyleSubheadline]
                                          range:hashtagRange];
                         }];
}

@end
