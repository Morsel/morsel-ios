//
//  MRSLMorselSettingsViewController.m
//  Morsel
//
//  Created by Javier Otero on 3/7/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLMorselPublishViewController.h"

#import "MRSLItemImageView.h"
#import "MRSLMorselPublishShareViewController.h"

#import "MRSLMorsel.h"

@interface MRSLMorselPublishViewController ()
<UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UILabel *morselTitleLabel;
@property (weak, nonatomic) IBOutlet MRSLItemImageView *coverMorselImageView;

@end

@implementation MRSLMorselPublishViewController

#pragma mark - Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    _coverMorselImageView.item = [_morsel coverItem];
    _morselTitleLabel.text = _morsel.title;
    [_morselTitleLabel addStandardShadow];
}

#pragma mark - Segue Methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"seg_PublishShareMorsel"]) {
        MRSLMorselPublishShareViewController *publishShareVC = [segue destinationViewController];
        publishShareVC.morsel = _morsel;
    }
}

@end
