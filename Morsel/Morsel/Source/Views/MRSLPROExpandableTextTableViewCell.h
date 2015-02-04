//
//  MRSLPROExpandableTextTableViewCell.h
//  Morsel
//
//  Created by Marty Trzpit on 1/28/15.
//  Copyright (c) 2015 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MRSLPROExpandableTextTableViewCellDelegate <NSObject>

@required
- (void)tableView:(UITableView *)tableview updatedText:(NSString *)text atIndexPath:(NSIndexPath *)indexPath;

@optional
- (void)tableView:(UITableView *)tableview updatedHeight:(CGFloat)updatedHeight atIndexPath:(NSIndexPath *)indexPath;
- (BOOL)tableView:(UITableView *)tableview textViewDidBeginEditing:(UITextView *)textView;
- (BOOL)tableView:(UITableView *)tableview textViewDidEndEditing:(UITextView *)textView;
- (void)tableView:(UITableView *)tableview makePrimaryItemAtIndexPath:(NSIndexPath *)indexPath;

@end


@interface MRSLPROExpandableTextTableViewCell : UITableViewCell <UITextViewDelegate>

@property (nonatomic, weak) UITableView *tableView;

- (void)becomeFirstResponderForTextView;
- (CGFloat)cellHeight;
- (void)setInputAccessoryView:(UIView *)inputAccessoryView;
- (void)setText:(NSString *)text;

@end
