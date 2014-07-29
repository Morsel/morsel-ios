//
//  MRSLMorselSettingsViewController.m
//  Morsel
//
//  Created by Javier Otero on 3/7/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLMorselPublishCoverViewController.h"

#import "MRSLAPIService+Morsel.h"

#import "MRSLImagePreviewCollectionViewCell.h"
#import "MRSLItemImageView.h"
#import "MRSLMorselPublishPlaceViewController.h"
#import "MRSLMorselPublishShareViewController.h"

#import "MRSLItem.h"
#import "MRSLMorsel.h"
#import "MRSLUser.h"

@interface MRSLMorselPublishCoverViewController ()
<UICollectionViewDataSource,
UICollectionViewDelegate>

@property (nonatomic) int morselID;

@property (weak, nonatomic) IBOutlet UILabel *morselTitleLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *coverCollectionView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@end

@implementation MRSLMorselPublishCoverViewController

#pragma mark - Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    _morselTitleLabel.text = _morsel.title;
    [_morselTitleLabel addStandardShadow];

    _pageControl.numberOfPages = [_morsel.items count];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    if (self.morsel) {
        self.morselID = self.morsel.morselIDValue;
        NSUInteger coverIndex = [[self.morsel itemsArray] indexOfObject:[self.morsel coverItem]];
        if (coverIndex != NSNotFound) {
            [self.coverCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:coverIndex inSection:0]
                                             atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                                     animated:NO];
        }
    }
}

#pragma mark - Action Methods

- (IBAction)next:(id)sender {
    [self updateMorsel];
    if (!_morsel) self.morsel = [MRSLMorsel MR_findFirstByAttribute:MRSLMorselAttributes.morselID
                                                          withValue:@(_morselID)];
    [_appDelegate.apiService updateMorsel:_morsel
                                  success:nil
                                  failure:nil];
    [self performSegueWithIdentifier:([[MRSLUser currentUser] isProfessional]) ? MRSLStoryboardSegueSelectPlaceKey : MRSLStoryboardSeguePublishShareMorselKey
                              sender:nil];
}

#pragma mark - Private Methods

- (void)updateMorsel {
    NSIndexPath *selectedCoverIndexPath = [self.coverCollectionView indexPathForCell:[[self.coverCollectionView visibleCells] firstObject]];
    MRSLItem *coverItem = [[self.morsel itemsArray] objectAtIndex:selectedCoverIndexPath.row];
    self.morsel.primary_item_id = coverItem.itemID;
}

#pragma mark - Segue Methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:MRSLStoryboardSegueSelectPlaceKey]) {
        MRSLMorselPublishPlaceViewController *publishPlaceVC = [segue destinationViewController];
        publishPlaceVC.morsel = _morsel;
    } else if ([segue.identifier isEqualToString:MRSLStoryboardSeguePublishShareMorselKey]) {
        MRSLMorselPublishShareViewController *publishShareVC = [segue destinationViewController];
        publishShareVC.morsel = _morsel;
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [[_morsel items] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MRSLItem *item = [[_morsel itemsArray] objectAtIndex:indexPath.row];
    MRSLImagePreviewCollectionViewCell *imagePreviewCell = [collectionView dequeueReusableCellWithReuseIdentifier:MRSLStoryboardRUIDMediaPreviewCellKey
                                                                                                     forIndexPath:indexPath];
    imagePreviewCell.mediaPreviewItem = item;
    return imagePreviewCell;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    int page = _coverCollectionView.contentOffset.x / _coverCollectionView.frame.size.width;
    self.pageControl.currentPage = page;
}

#pragma mark - Dealloc

- (void)reset {
    [super reset];
    self.coverCollectionView.delegate = nil;
    self.coverCollectionView.dataSource = nil;
    [self.coverCollectionView removeFromSuperview];
    self.coverCollectionView = nil;
}

@end
