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
                               delegate:(id /*<UIAlertViewDelegate>*/)delegate
                      cancelButtonTitle:(NSString *)cancelButtonTitle
                      otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:delegate
                                              cancelButtonTitle:cancelButtonTitle
                                              otherButtonTitles:nil];

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

+ (UIAlertView *)showAlertViewForError:(NSError *)error
                              delegate:(id /*<UIAlertViewDelegate>*/)delegate {
    return [UIAlertView showAlertViewWithTitle:@"Error"
                                       message:[error localizedDescription]
                                      delegate:delegate
                             cancelButtonTitle:@"OK"
                             otherButtonTitles:nil];
}

+ (UIAlertView *)showAlertViewForServiceError:(MRSLServiceErrorInfo *)serviceError
                                     delegate:(id /*<UIAlertViewDelegate>*/)delegate {
    return [UIAlertView showAlertViewWithTitle:@"Oops, there's been a problem!"
                                       message:[serviceError errorInfo]
                                      delegate:delegate
                             cancelButtonTitle:@"OK"
                             otherButtonTitles:nil];
}

@end
