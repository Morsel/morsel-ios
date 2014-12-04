//
//  MRSLStandardTextView.h
//  Morsel
//
//  Created by Javier Otero on 10/20/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MRSLStandardTextView : UITextView

+ (MRSLStandardTextView *)textViewWithHashtagHighlightingFromAttributedString:(NSAttributedString *)string
                                                                        frame:(CGRect)frame
                                                                     delegate:(id)delegate;
- (void)setUp;

@end
