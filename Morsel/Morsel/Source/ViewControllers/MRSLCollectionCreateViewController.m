//
//  MRSLCollectionAddViewController.m
//  Morsel
//
//  Created by Javier Otero on 1/27/15.
//  Copyright (c) 2015 Morsel. All rights reserved.
//

#import "MRSLCollectionCreateViewController.h"

#import "MRSLAPIService+Collection.h"

#import "MRSLPlaceholderTextView.h"

#import "MRSLCollection.h"

@interface MRSLCollectionCreateViewController ()

@property (weak, nonatomic) IBOutlet UITextField *collectionTitleField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *createBarButton;

@property (weak, nonatomic) IBOutlet MRSLPlaceholderTextView *collectionDescriptionField;

@end

@implementation MRSLCollectionCreateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = (self.collection) ? @"Edit collection" : @"Create collection";
    self.mp_eventView = (self.collection) ? @"collection-edit" : @"collection-create";
    self.collectionDescriptionField.placeholder = @"Give your collection a description";

    if (self.collection) {
        [self.createBarButton setTitle:@"Save"];
        self.collectionTitleField.text = self.collection.title;
        self.collectionDescriptionField.text = self.collection.collectionDescription;
    }
}

- (BOOL)isDirty {
    return (![[self.collection title] isEqualToString:self.collectionTitleField.text] ||
            ![[self.collection collectionDescription] isEqualToString:self.collectionDescriptionField.text]);
}

- (void)goBack {
    if (self.collection && [self isDirty]) {
        [UIAlertView showAlertViewWithTitle:@"Warning"
                                    message:@"You have unsaved changes, are you sure you want to discard them?"
                                   delegate:self
                          cancelButtonTitle:@"Cancel"
                          otherButtonTitles:@"Discard", nil];
    } else {
        [super goBack];
    }
}

- (IBAction)createCollection:(id)sender {
    if ([self.collectionTitleField.text length] == 0 ||
        self.collectionTitleField.text.length > 70) {
        [UIAlertView showAlertViewWithTitle:@"Invalid Title"
                                    message:@"Title must not be empty and contain less than 70 characters."
                                   delegate:nil
                          cancelButtonTitle:@"Close"
                          otherButtonTitles:nil];
    } else {
        if (self.collection) {
            [self.createBarButton setEnabled:NO];
            self.collection.title = self.collectionTitleField.text;
            self.collection.collectionDescription = self.collectionDescriptionField.text;
            __weak __typeof(self) weakSelf = self;
            [_appDelegate.apiService updateCollection:self.collection
                                              success:^(id responseObject) {
                                                  [weakSelf goBack];
                                              } failure:^(NSError *error) {
                                                  [UIAlertView showAlertViewForErrorString:@"Unable to update collection. Please try again."
                                                                                  delegate:nil];
                                                  [weakSelf.createBarButton setEnabled:YES];
                                              }];
        } else {
            [self.createBarButton setEnabled:NO];
            __weak __typeof(self) weakSelf = self;
            [_appDelegate.apiService createCollectionWithTitle:self.collectionTitleField.text
                                                   description:self.collectionDescriptionField.text
                                                       success:^(id responseObject) {
                                                           if (weakSelf) {
                                                               if (weakSelf.morsel && [responseObject isKindOfClass:[MRSLCollection class]]) {
                                                                   [_appDelegate.apiService addMorsel:weakSelf.morsel
                                                                                         toCollection:(MRSLCollection *)responseObject
                                                                                             withNote:nil
                                                                                              success:^(id responseObject) {
                                                                                                  [weakSelf dismiss];
                                                                                              }
                                                                                              failure:^(NSError *error) {
                                                                                                  [UIAlertView showAlertViewForErrorString:@"Error adding to newly created collection. Please try again."
                                                                                                                                  delegate:nil];
                                                                                                  [weakSelf goBack];
                                                                                              }];
                                                               } else {
                                                                   [weakSelf goBack];
                                                               }
                                                           }
                                                       }
                                                       failure:^(NSError *error) {
                                                           [UIAlertView showAlertViewForErrorString:@"Unable to create collection. Please try again."
                                                                                           delegate:nil];
                                                           [weakSelf.createBarButton setEnabled:YES];
                                                       }];
        }
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Discard"]) {
        [super goBack];
    }
}

@end
