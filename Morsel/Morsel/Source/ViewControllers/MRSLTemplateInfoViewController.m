//
//  MRSLTemplateInfoViewController.m
//  Morsel
//
//  Created by Javier Otero on 8/20/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLTemplateInfoViewController.h"

#import "MRSLAPIService+Templates.h"

#import "MRSLMorselEditViewController.h"
#import "MRSLMorsel.h"
#import "MRSLSectionView.h"
#import "MRSLTemplate.h"
#import "MRSLTemplateItem.h"
#import "MRSLTemplateItemInfoTableViewCell.h"

@interface MRSLTemplateInfoViewController ()
<UITableViewDataSource,
UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *proTipLabel;
@property (weak, nonatomic) IBOutlet UIButton *createButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MRSLTemplateInfoViewController

#pragma mark - Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];

    if (_isDisplayingHelp) {
        self.createButton.hidden = YES;
        self.navigationItem.rightBarButtonItem = nil;
    }

    CGSize descriptionSize = (_morselTemplate.templateDescription) ? [_morselTemplate.templateDescription sizeWithFont:_descriptionLabel.font
                                                                                                     constrainedToSize:CGSizeMake([_descriptionLabel getWidth], CGFLOAT_MAX)
                                                                                                         lineBreakMode:NSLineBreakByWordWrapping] : CGSizeZero;
    CGSize proTipSize = (_morselTemplate.tip) ? [[NSString stringWithFormat:@"Pro Tip: %@", _morselTemplate.tip] sizeWithFont:_proTipLabel.font
                                                                                                            constrainedToSize:CGSizeMake([_proTipLabel getWidth], CGFLOAT_MAX)
                                                                                                                lineBreakMode:NSLineBreakByWordWrapping] : CGSizeZero;

    self.title = _morselTemplate.title ?: @"Storyboard";
    self.descriptionLabel.text = _morselTemplate.templateDescription ?: @"";
    self.proTipLabel.text = _morselTemplate.tip ? [NSString stringWithFormat:@"Pro Tip: %@", _morselTemplate.tip] : @"";

    [self.descriptionLabel setHeight:descriptionSize.height];
    [self.proTipLabel setHeight:proTipSize.height];

    [self.proTipLabel setY:[_descriptionLabel getHeight] + [_descriptionLabel getY] + 10.f];

    if (_isDisplayingHelp) {
        [self.tableView setY:([UIDevice has35InchScreen] ? 50.f : 0.f) + ([_proTipLabel getHeight] + [_proTipLabel getY] + 10.f)];
    } else {
        [self.createButton setY:[_proTipLabel getHeight] + [_proTipLabel getY] + 10.f];
        [self.tableView setY:(([UIDevice has35InchScreen] || SYSTEM_VERSION_LESS_THAN(@"7.0")) ? 50.f : 0.f) + ([_createButton getHeight] + [_createButton getY] + 10.f)];
    }

    [self.tableView setHeight:[self.view getHeight] - [self.tableView getY]];

    [self.tableView reloadData];

    if ([self.morselTemplate.items count] == 0) self.tableView.hidden = YES;
}

#pragma mark - Action Methods

- (IBAction)create:(id)sender {
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.createButton.enabled = NO;
    __weak __typeof(self) weakSelf = self;
    [_appDelegate.apiService createMorselWithTemplate:_morselTemplate
                                              success:^(id responseObject) {
                                                  if ([responseObject isKindOfClass:[MRSLMorsel class]]) {
                                                      MRSLMorselEditViewController *editMorselVC = [[UIStoryboard morselManagementStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardMorselEditViewControllerKey];
                                                      editMorselVC.morselID = [(MRSLMorsel *)responseObject morselID];
                                                      editMorselVC.wasNewMorsel = YES;
                                                      [weakSelf.navigationController pushViewController:editMorselVC
                                                                                               animated:YES];
                                                  }
                                              } failure:^(NSError *error) {
                                                  [UIAlertView showAlertViewForErrorString:@"Unable to create morsel. Please try again."
                                                                                  delegate:nil];
                                                  weakSelf.navigationItem.rightBarButtonItem.enabled = YES;
                                                  weakSelf.createButton.enabled = YES;
                                              }];
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.morselTemplate.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MRSLTemplateItem *templateItem = [_morselTemplate.itemsArray objectAtIndex:indexPath.row];
    MRSLTemplateItemInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MRSLStoryboardRUIDTemplateInfoCell];
    [cell setTemplateItem:templateItem];
    return cell;
}

#pragma mark - UITableViewDelegate Methods

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [MRSLSectionView sectionViewWithTitle:@"Photo list"];
}


@end
