//
//  MorselDetailViewController.m
//  Morsel
//
//  Created by Javier Otero on 12/16/13.
//  Copyright (c) 2013 Morsel. All rights reserved.
//

#import "MorselDetailViewController.h"

#import <NSDate+TimeAgo/NSDate+TimeAgo.h>

#import "ModelController.h"
#import "MorselScrollView.h"
#import "ProfileImageView.h"
#import "ProfileViewController.h"

#import "MRSLMorsel.h"
#import "MRSLPost.h"
#import "MRSLUser.h"

@interface MorselDetailViewController ()

<
UIScrollViewDelegate
>

@property (weak, nonatomic) IBOutlet UILabel *authorNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeSinceLabel;
@property (weak, nonatomic) IBOutlet UILabel *postTitleLabel;
@property (weak, nonatomic) IBOutlet UIPageControl *progressionPageControl;
@property (weak, nonatomic) IBOutlet UIView *morselDetailNavigationView;
@property (weak, nonatomic) IBOutlet UIView *profilePanelView;

@property (weak, nonatomic) IBOutlet MorselScrollView *morselScrollView;
@property (weak, nonatomic) IBOutlet ProfileImageView *profileImageView;

@end

@implementation MorselDetailViewController

#pragma mark - Instance Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (_morsel && _morsel.post)
    {
        NSUInteger postMorselCount = [_morsel.post.morsels count];
        
        if (postMorselCount > 1)
        {
            self.progressionPageControl.numberOfPages = postMorselCount;
        }
        else
        {
            self.progressionPageControl.hidden = YES;
            [self.morselDetailNavigationView setHeight:64.f];
        }
        
        self.postTitleLabel.text = _morsel.post.title ? : @"Morsel";
        self.timeSinceLabel.text = [_morsel.creationDate dateTimeAgo];
        self.authorNameLabel.text = [_morsel.post.author fullName];
        
        self.profileImageView.user = _morsel.post.author;
        [_profileImageView addCornersWithRadius:20.f];
        
        int morselIndex = (int)[_morsel.post.morsels indexOfObject:_morsel];
        
        self.morselScrollView.contentInset = UIEdgeInsetsMake(55.f, 0.f, 0.f, 0.f);
        self.morselScrollView.post = _morsel.post;
        [self.morselScrollView scrollToMorsel:_morsel];
        
        [self displayMorselDetailForPage:morselIndex];
    }
}

#pragma mark - Section Methods

- (IBAction)displayUserProfile
{
    ProfileViewController *profileVC = [[UIStoryboard profileStoryboard] instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    profileVC.user = _morsel.post.author;
    
    [self.navigationController pushViewController:profileVC
                                         animated:YES];
}

#pragma mark - Private Methods

- (IBAction)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)displayMorselDetailForPage:(int)page
{
    if ([_morsel.post.morsels count] < page) return;
    
    MRSLMorsel *morsel = [_morsel.post.morsels objectAtIndex:page];
    
    self.morsel = morsel;
    
    self.progressionPageControl.currentPage = page;
}

- (void)changeMorselDetail
{
    CGFloat scrollWidth = _morselScrollView.frame.size.width;
    float scrollPage = _morselScrollView.contentOffset.x / scrollWidth;
    int actualPage = scrollPage;
    
    [self displayMorselDetailForPage:actualPage];
}

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
    {
        [self changeMorselDetail];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self changeMorselDetail];
}

#pragma mark - Destruction Methods

- (void)dealloc
{
    [self.morselScrollView reset];
}

@end
