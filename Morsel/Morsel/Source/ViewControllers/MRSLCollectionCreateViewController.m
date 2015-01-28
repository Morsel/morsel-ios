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

@interface MRSLCollectionCreateViewController ()

@property (weak, nonatomic) IBOutlet UITextField *collectionTitleField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *createBarButton;

@property (weak, nonatomic) IBOutlet MRSLPlaceholderTextView *collectionDescriptionField;

@end

@implementation MRSLCollectionCreateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Create collection";
    self.mp_eventView = @"collection-create";
    self.collectionDescriptionField.placeholder = @"Give your collection a description";
}

- (IBAction)createCollection:(id)sender {
    if ([self.collectionTitleField.text length] == 0 ||
        self.collectionTitleField.text.length > 70) {
        [UIAlertView showAlertViewWithTitle:@"Invalid Title"
                                    message:@"Title must contain at less than 70 characters."
                                   delegate:nil
                          cancelButtonTitle:@"Close"
                          otherButtonTitles:nil];
    } else {
        [self.createBarButton setEnabled:NO];
        __weak __typeof(self) weakSelf = self;
        [_appDelegate.apiService createCollectionWithTitle:self.collectionTitleField.text
                                               description:self.collectionDescriptionField.text
                                                   success:^(id responseObject) {
                                                       if (weakSelf) {
                                                           [weakSelf goBack];
                                                       }
                                                   }
                                                   failure:^(NSError *error) {
                                                       [UIAlertView showAlertViewForErrorString:@"Unable to create collection. Please try again."
                                                                                       delegate:nil];
                                                       [weakSelf.createBarButton setEnabled:YES];
                                                   }];
    }
}


@end
