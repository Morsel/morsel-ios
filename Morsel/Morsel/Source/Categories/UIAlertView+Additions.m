//
//  UIAlertView+Additions.m
//  Morsel
//
//  Created by Marty Trzpit on 2/4/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "UIAlertView+Additions.h"

#import "MRSLServiceErrorInfo.h"

@implementation UIAlertView (Additions)

#pragma mark - Class Methods

+ (UIAlertView *)showAlertViewWithTitle:(NSString *)title
                                message:(NSString *)message
                               delegate:(id)delegate
                      cancelButtonTitle:(NSString *)cancelButtonTitle
                      otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION {
    NSString *alertMessage = message ?: @"Unknown error";
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:alertMessage
                                                       delegate:delegate
                                              cancelButtonTitle:cancelButtonTitle
                                              otherButtonTitles:nil];

    [[MRSLEventManager sharedManager] track:@"User viewed error"
                          properties:@{@"view": @"Alert",
                                       @"message": NSNullIfNil(alertMessage)}];
    if (otherButtonTitles != nil) {
        [alertView addButtonWithTitle:otherButtonTitles];
        va_list args;
        va_start(args, otherButtonTitles);
        NSString * title = nil;
        while((title = va_arg(args,NSString*))) {
            [alertView addButtonWithTitle:title];
        }
        va_end(args);
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [alertView show];
    });
    return alertView;
}

+ (UIAlertView *)showAlertViewWithTitle:(NSString *)title
                                message:(NSString *)message
                               delegate:(id /*<UIAlertViewDelegate>*/)delegate
                                  style:(UIAlertViewStyle)alertViewStyle
                      cancelButtonTitle:(NSString *)cancelButtonTitle
                      otherButtonTitles:(NSString *)otherButtonTitles, ... {
    UIAlertView *alertView = [UIAlertView showAlertViewWithTitle:title
                                                         message:message
                                                        delegate:delegate
                                               cancelButtonTitle:cancelButtonTitle
                                               otherButtonTitles:otherButtonTitles, nil];
    alertView.alertViewStyle = alertViewStyle;
    return alertView;
}

+ (UIAlertView *)showAlertViewForError:(NSError *)error
                              delegate:(id)delegate {
    return [UIAlertView showAlertViewForErrorString:[error localizedDescription]
                                           delegate:delegate];
}

+ (UIAlertView *)showAlertViewForErrorString:(NSString *)errorString
                                    delegate:(id)delegate {
    return [UIAlertView showAlertViewWithTitle:@"Something went wrong"
                                       message:errorString
                                      delegate:delegate
                             cancelButtonTitle:@"Close"
                             otherButtonTitles:nil];
}

+ (UIAlertView *)showAlertViewForServiceError:(MRSLServiceErrorInfo *)serviceError
                                     delegate:(id)delegate {
    return [UIAlertView showAlertViewForErrorString:([serviceError errorInfo] ?: @"Service error")
                                           delegate:delegate];
}

@end
