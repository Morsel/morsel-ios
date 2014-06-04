//
//  UIAlertView+Additions.h
//  Morsel
//
//  Created by Marty Trzpit on 2/4/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MRSLServiceErrorInfo;

@interface UIAlertView (Additions)

+ (UIAlertView *)showAlertViewWithTitle:(NSString *)title
                                message:(NSString *)message
                               delegate:(id /*<UIAlertViewDelegate>*/)delegate
                      cancelButtonTitle:(NSString *)cancelButtonTitle
                      otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

+ (UIAlertView *)showAlertViewWithTitle:(NSString *)title
                                message:(NSString *)message
                               delegate:(id /*<UIAlertViewDelegate>*/)delegate
                                  style:(UIAlertViewStyle)alertViewStyle
                      cancelButtonTitle:(NSString *)cancelButtonTitle
                      otherButtonTitles:(NSString *)otherButtonTitles, ...;

+ (UIAlertView *)showAlertViewForError:(NSError *)error
                              delegate:(id /*<UIAlertViewDelegate>*/)delegate;

+ (UIAlertView *)showAlertViewForServiceError:(MRSLServiceErrorInfo *)serviceError
                                     delegate:(id /*<UIAlertViewDelegate>*/)delegate;

+ (UIAlertView *)showAlertViewForErrorString:(NSString *)errorString
                                    delegate:(id /*<UIAlertViewDelegate>*/)delegate;

@end
