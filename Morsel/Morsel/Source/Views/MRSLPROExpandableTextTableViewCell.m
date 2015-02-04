//
//  MRSLPROExpandableTextTableViewCell.m
//  Morsel
//
//  Created by Marty Trzpit on 1/28/15.
//  Copyright (c) 2015 Morsel. All rights reserved.
//

#import "MRSLPROExpandableTextTableViewCell.h"

#import "MRSLPROTextView.h"

@interface MRSLPROExpandableTextTableViewCell()

@property (nonatomic, weak) IBOutlet MRSLPROTextView *textView;

@end

@implementation MRSLPROExpandableTextTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.textView setTextContainerInset:UIEdgeInsetsZero];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    if (self.textView != nil) {
        self.textView.frame = CGRectMake(CGRectGetMinX(self.frame),
                                         CGRectGetMinY(self.textView.frame),
                                         CGRectGetWidth(self.frame),
                                         [self textViewHeight]);
    }
}

- (void)becomeFirstResponderForTextView {
    [self.textView becomeFirstResponder];
}

- (CGFloat)cellHeight {
    return [self textViewHeight];
}

- (void)setInputAccessoryView:(UIView *)inputAccessoryView {
    [self.textView setInputAccessoryView:inputAccessoryView];
}

- (void)setText:(NSString *)text {
    [self.textView setText:text];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self textViewDidChange:self.textView];
    });
}


#pragma mark - Private Methods

- (CGFloat)minimumHeight {
    return 60.0f;
}

- (CGFloat)textViewHeight {
    if ([self.textView.text isEmpty]) {
        return [self minimumHeight];
    } else {
        CGSize size = [self.textView sizeThatFits:CGSizeMake(CGRectGetWidth(self.textView.frame), CGFLOAT_MAX)];
        return MAX(size.height, [self minimumHeight]);
    }
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    id tableViewDelegate = self.tableView.delegate;
    if ([tableViewDelegate respondsToSelector:@selector(tableView:textViewDidBeginEditing:)]) {
        [tableViewDelegate tableView:self.tableView
             textViewDidBeginEditing:textView];
    }
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    id tableViewDelegate = self.tableView.delegate;
    if ([tableViewDelegate respondsToSelector:@selector(tableView:textViewDidEndEditing:)]) {
        return [tableViewDelegate tableView:self.tableView
                      textViewDidEndEditing:textView];
    } else {
        return YES;
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    id tableViewDelegate = self.tableView.delegate;
    if ([tableViewDelegate respondsToSelector:@selector(tableView:updatedText:atIndexPath:)]) {
        id indexPath = [self.tableView indexPathForCell:self];
        if (indexPath == nil) return;

        [tableViewDelegate tableView:self.tableView
                         updatedText:textView.text
                         atIndexPath:indexPath];

        CGFloat newHeight = [self cellHeight];
        CGFloat oldHeight = [tableViewDelegate tableView:self.tableView
                                 heightForRowAtIndexPath:indexPath];

        if (ABS(newHeight - oldHeight) > 0.01f) {
            if ([tableViewDelegate respondsToSelector:@selector(tableView:updatedHeight:atIndexPath:)]) {
                [tableViewDelegate tableView:self.tableView
                               updatedHeight:newHeight
                                 atIndexPath:indexPath];

            }
        }
    }

    [self.tableView beginUpdates];
    [self setNeedsLayout];
    [self.tableView endUpdates];
}

@end
