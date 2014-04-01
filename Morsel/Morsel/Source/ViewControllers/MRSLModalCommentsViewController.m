//
//  MRSLModalCommentsViewController.m
//  Morsel
//
//  Created by Javier Otero on 3/31/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLModalCommentsViewController.h"

#import <GCPlaceholderTextView/GCPlaceholderTextView.h>

#import "MRSLCommentTableViewCell.h"

#import "MRSLComment.h"
#import "MRSLMorsel.h"

static const CGFloat MRSLDefaultCommentLabelHeight = 14.f;
static const CGFloat MRSLDefaultCommentLabelWidth = 192.f;

@interface MRSLModalCommentsViewController ()
<UITableViewDataSource,
UITableViewDelegate,
NSFetchedResultsControllerDelegate>

@property (nonatomic) NSInteger commentCount;

@property (weak, nonatomic) IBOutlet UITableView *commentsTableView;
@property (weak, nonatomic) IBOutlet UIView *commentInputView;
@property (weak, nonatomic) IBOutlet GCPlaceholderTextView *commentInputTextView;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end

@implementation MRSLModalCommentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

    self.commentInputTextView.placeholder = @"Write a comment...";
    self.commentInputTextView.placeholderColor = [UIColor morselLightContent];

    [_appDelegate.morselApiService getComments:_morsel
                                       success:nil
                                       failure:nil];
}

- (void)setMorsel:(MRSLMorsel *)morsel {
    if (_morsel != morsel) {
        _morsel = morsel;
        if (_morsel && !_fetchedResultsController) {
            NSPredicate *commentsForMorselPredicate = [NSPredicate predicateWithFormat:@"morsel.morselID == %i", [_morsel.morselID intValue]];

            self.fetchedResultsController = [MRSLComment MR_fetchAllSortedBy:@"creationDate"
                                                                   ascending:YES
                                                               withPredicate:commentsForMorselPredicate
                                                                     groupBy:nil
                                                                    delegate:self
                                                                   inContext:[NSManagedObjectContext MR_defaultContext]];

            [self.commentsTableView reloadData];
        }
    }
}

#pragma mark - Action Methods

- (IBAction)addComment {
    if (_morsel) {
        if (_commentInputTextView.text.length > 0) {
            [_commentInputTextView resignFirstResponder];
            [_appDelegate.morselApiService postCommentWithDescription:_commentInputTextView.text
                                                             toMorsel:_morsel
                                                              success:^(id responseObject) {
                                                                  if (_commentsTableView.contentSize.height > [_commentsTableView getHeight]) {
                                                                      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                                          CGPoint bottomOffset = CGPointMake(0, _commentsTableView.contentSize.height - _commentsTableView.bounds.size.height);
                                                                          [_commentsTableView setContentOffset:bottomOffset
                                                                                                      animated:YES];
                                                                      });
                                                                  }
                                                              } failure:nil];
            _commentInputTextView.text = nil;
        } else {
            [UIAlertView showAlertViewForErrorString:@"Please add some text to submit a comment!"
                                            delegate:nil];
        }
    }
}

- (IBAction)dismiss:(id)sender {
    if ([_commentInputTextView isFirstResponder] && ![sender isKindOfClass:[UIButton class]]) {
        [_commentInputTextView resignFirstResponder];
    } else {
        [super dismiss:sender];
    }
}

#pragma mark - Notification Methods

- (void)keyboardWillShow:(NSNotification *)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGFloat baselineY = self.view.frame.size.height - keyboardSize.height;
    [UIView animateWithDuration:.35f
                     animations:^{
                         [_commentInputView setY:baselineY - [_commentInputView getHeight]];
                         [_commentsTableView setHeight:[_commentInputView getY] - [_commentsTableView getY]];
                         if (_commentsTableView.contentSize.height > [_commentsTableView getHeight]) {
                             CGPoint bottomOffset = CGPointMake(0, _commentsTableView.contentSize.height - _commentsTableView.bounds.size.height);
                             [_commentsTableView setContentOffset:bottomOffset
                                                         animated:NO];
                         }
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [UIView animateWithDuration:.2f
                     animations:^{
                         [_commentInputView setY:self.view.frame.size.height - [_commentInputView getHeight]];
                         [_commentsTableView setHeight:[_commentInputView getY] - [_commentsTableView getY]];
                     }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id<NSFetchedResultsSectionInfo> sectionInfo = [[_fetchedResultsController sections] objectAtIndex:section];
    self.commentCount = [sectionInfo numberOfObjects];
    return _commentCount;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    MRSLComment *comment = [_fetchedResultsController objectAtIndexPath:indexPath];
    CGSize bodySize = [comment.commentDescription sizeWithFont:[UIFont helveticaLightObliqueFontOfSize:12.f]
                                             constrainedToSize:CGSizeMake(MRSLDefaultCommentLabelWidth, CGFLOAT_MAX)
                                                 lineBreakMode:NSLineBreakByWordWrapping];
    CGFloat defaultCellSize = 110.f;

    if (bodySize.height > MRSLDefaultCommentLabelHeight) {
        defaultCellSize = defaultCellSize + (bodySize.height - MRSLDefaultCommentLabelHeight);
    }
    return defaultCellSize;
}

- (MRSLCommentTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MRSLComment *comment = [_fetchedResultsController objectAtIndexPath:indexPath];

    MRSLCommentTableViewCell *commentCell = [self.commentsTableView dequeueReusableCellWithIdentifier:@"ruid_CommentCell"];
    commentCell.comment = comment;
    commentCell.pipeView.hidden = (indexPath.row == _commentCount - 1);

    return commentCell;
}

#pragma mark - NSFetchedResultsControllerDelegate Methods

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    NSArray *comments = [controller fetchedObjects];
    if ([comments count] > 0) {
        DDLogDebug(@"Fetch controller detected change in content. Reloading with %lu comments.", (unsigned long)[comments count]);
        NSError *fetchError = nil;
        [_fetchedResultsController performFetch:&fetchError];
        if (fetchError) {
            DDLogDebug(@"Refresh Fetch Failed! %@", fetchError.userInfo);
        }
        [self.commentsTableView reloadData];
    }
}

#pragma mark - UITextViewDelegate Methods

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [self addComment];
        return NO;
    } else {
        return YES;
    }

    return YES;
}

#pragma mark - Destroy Methods

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
