//
//  MRSLPROItemTableViewCell.m
//  Morsel
//
//  Created by Marty Trzpit on 1/28/15.
//  Copyright (c) 2015 Morsel. All rights reserved.
//

#import "MRSLPROItemTableViewCell.h"

#import "UIImage+Color.h"
#import "UITableViewCell+Additions.h"

#import "MRSLPROTextView.h"

static NSString * const kDeleteThisItem = @"Delete This Item";
static NSString * const kMakeCoverPhoto = @"Make Cover Photo";

@interface MRSLPROExpandableTextTableViewCell()

@property (nonatomic, weak) IBOutlet MRSLPROTextView *textView;

@end

@interface MRSLPROItemTableViewCell()

@property (nonatomic, weak) IBOutlet UIImageView *itemImageView;
@property (nonatomic, strong) IBOutletCollection(UIView) NSArray *viewsToHideDuringReorder;

@end

@implementation MRSLPROItemTableViewCell

#pragma mark - Instance Methods

- (void)layoutSubviews {
    [super layoutSubviews];

    self.itemImageView.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame), CGRectGetWidth(self.frame));
    self.textView.frame = CGRectMake(0.0f, CGRectGetMaxY(self.itemImageView.frame), CGRectGetWidth(self.itemImageView.frame), CGRectGetHeight(self.textView.frame));
}

- (void)shouldHideEverythingButImage:(BOOL)shouldHideEverythingButImage {
    [self.viewsToHideDuringReorder enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
        [subview setHidden:shouldHideEverythingButImage];
    }];
}

- (BOOL)shouldAllowReorder {
    return YES;
}

#pragma mark IBActions

- (IBAction)showItemInfo:(id)sender {
    [self.textView resignFirstResponder];
    id actionSheet = [[UIActionSheet alloc] initWithTitle:@"Item Options"
                                                 delegate:self
                                        cancelButtonTitle:@"Cancel"
                                   destructiveButtonTitle:kDeleteThisItem
                                        otherButtonTitles:kMakeCoverPhoto, nil];

    [actionSheet showInView:self.tableView];
}


#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self.tableView.superview endEditing:YES];
    [self endEditing:YES];

    id buttonTitleAtIndex = [actionSheet buttonTitleAtIndex:buttonIndex];

    id tableViewDelegate = self.tableView.delegate;

    if ([buttonTitleAtIndex isEqualToString:kDeleteThisItem]) {
        if ([tableViewDelegate respondsToSelector:@selector(tableView:commitEditingStyle:forRowAtIndexPath:)]) {
            [tableViewDelegate tableView:self.tableView
                      commitEditingStyle:UITableViewCellEditingStyleDelete
                       forRowAtIndexPath:[self.tableView indexPathForCell:self]];
        }
    } else if ([buttonTitleAtIndex isEqualToString:kMakeCoverPhoto]) {
        if ([tableViewDelegate respondsToSelector:@selector(tableView:makePrimaryItemAtIndexPath:)]) {
            [tableViewDelegate tableView:self.tableView
              makePrimaryItemAtIndexPath:[self.tableView indexPathForCell:self]];
        }
    }
}

@end
