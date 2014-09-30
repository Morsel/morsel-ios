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

    self.mp_eventView = @"storyboard_detail";
    if (_isDisplayingHelp) {
        self.createButton.hidden = YES;
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.descriptionLabel setPreferredMaxLayoutWidth:self.view.frame.size.width - 40.f];
    [self.proTipLabel setPreferredMaxLayoutWidth:self.view.frame.size.width - 40.f];

    self.title = _morselTemplate.title ?: @"Storyboard";
    self.descriptionLabel.text = _morselTemplate.templateDescription ?: @"";
    self.proTipLabel.text = _morselTemplate.tip ? [NSString stringWithFormat:@"Pro Tip: %@", _morselTemplate.tip] : @"";

    [self.tableView reloadData];

    if ([self.morselTemplate.items count] == 0) self.tableView.hidden = YES;
}

#pragma mark - Action Methods

- (IBAction)create:(id)sender {
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.createButton.enabled = NO;
    [[MRSLEventManager sharedManager] track:@"Tapped Create morsel"
                                 properties:@{@"_title": NSNullIfNil(_morselTemplate.title),
                                              @"_view": self.mp_eventView,
                                              @"pressed_nav_button": ([sender isEqual:_createButton]) ? @"false" : @"true"}];
    __weak __typeof(self) weakSelf = self;
    [_appDelegate.apiService createMorselWithTemplate:_morselTemplate
                                              success:^(id responseObject) {
                                                  if ([responseObject isKindOfClass:[MRSLMorsel class]]) {
                                                      MRSLMorselEditViewController *editMorselVC = [[UIStoryboard morselManagementStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardMorselEditViewControllerKey];
                                                      editMorselVC.morselID = [(MRSLMorsel *)responseObject morselID];
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
