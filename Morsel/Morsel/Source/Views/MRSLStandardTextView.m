//
//  MRSLStandardTextView.m
//  Morsel
//
//  Created by Javier Otero on 10/20/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLStandardTextView.h"

#import "MRSLHashtagHighlightTextStorage.h"

@implementation MRSLStandardTextView

#pragma mark - Class Methods

+ (MRSLStandardTextView *)textViewWithHashtagHighlightingFromAttributedString:(NSAttributedString *)string
                                                                        frame:(CGRect)frame
                                                                     delegate:(id)delegate  {
    // 1. Create the text storage that backs the editor
    MRSLHashtagHighlightTextStorage *textStorage = [MRSLHashtagHighlightTextStorage new];
    if (string) [textStorage appendAttributedString:string];

    // 2. Create the layout manager
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];

    // 3. Create a text container
    CGSize containerSize = CGSizeMake(frame.size.width,  CGFLOAT_MAX);
    NSTextContainer *container = [[NSTextContainer alloc] initWithSize:containerSize];
    container.widthTracksTextView = YES;
    [layoutManager addTextContainer:container];
    [textStorage addLayoutManager:layoutManager];

    // 4. Create a UITextView
    MRSLStandardTextView *textView = [[MRSLStandardTextView alloc] initWithFrame:frame
                                                                   textContainer:container];
    textView.delegate = delegate;
    return textView;
}

#pragma mark - Instance Methods

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setUp];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    return self;
}

#pragma mark - Override

- (void)setUp {
    self.linkTextAttributes = @{NSForegroundColorAttributeName: [UIColor morselPrimary],
                                NSUnderlineStyleAttributeName: @(NSUnderlineStyleNone)};
}

@end
