//
//  MorselDetailViewController.m
//  Morsel
//
//  Created by Javier Otero on 12/16/13.
//  Copyright (c) 2013 Morsel. All rights reserved.
//

#import "MorselDetailViewController.h"

#import "JSONResponseSerializerWithData.h"
#import "ModelController.h"
#import "MorselScrollView.h"
#import "ProfileImageView.h"

#import "MRSLMorsel.h"
#import "MRSLPost.h"
#import "MRSLUser.h"

@interface MorselDetailViewController ()

<
UIScrollViewDelegate
>

@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UILabel *authorNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *morselTitleLabel;
@property (weak, nonatomic) IBOutlet UITextView *morselDescriptionTextView;

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
        self.profileImageView.user = _morsel.post.author;
        self.authorNameLabel.text = [_morsel.post.author fullName];
        self.morselTitleLabel.text = _morsel.post.title;
        
        self.morselScrollView.post = _morsel.post;
        
        int morselIndex = [_morsel.post.morsels indexOfObject:_morsel];
        
        [self.morselScrollView scrollToMorsel:_morsel];
        [self displayMorselDetailForPage:morselIndex];
        
        [self setLikeButtonImageForMorsel:_morsel];
    }
}

#pragma mark - Private Methods

- (IBAction)goBack:(UIBarButtonItem *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)toggleLikeMorsel
{
    _likeButton.enabled = NO;
    
    [[ModelController sharedController].morselApiService likeMorsel:_morsel
                                                         shouldLike:!_morsel.likedValue
                                                            didLike:^(BOOL doesLike)
    {
        [_morsel setLikedValue:doesLike];
        
        [self setLikeButtonImageForMorsel:_morsel];
    }
                                                            failure:^(NSError *error)
    {
        NSDictionary *errorDictionary = error.userInfo[JSONResponseSerializerWithDataKey];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:errorDictionary ? [errorDictionary[@"errors"] objectAtIndex:0][@"msg"] : nil
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
        _likeButton.enabled = YES;
    }];
}

- (void)setLikeButtonImageForMorsel:(MRSLMorsel *)morsel
{
    UIImage *likeImage = [UIImage imageNamed:morsel.likedValue ? @"30-heart" : @"29-heart"];
    
    [_likeButton setImage:likeImage
                 forState:UIControlStateNormal];
    
    _likeButton.enabled = YES;
}

- (void)displayMorselDetailForPage:(int)page
{
    if ([_morsel.post.morsels count] < page) return;
    
    MRSLMorsel *morsel = [_morsel.post.morsels objectAtIndex:page];
    
    self.morsel = morsel;
    
    [self setLikeButtonImageForMorsel:morsel];
    
    self.morselDescriptionTextView.text = morsel.morselDescription;
}

- (void)changeMorselDetail
{
    CGFloat scrollWidth = _morselScrollView.frame.size.width;
    float scrollPage = _morselScrollView.contentOffset.x / scrollWidth;
    NSInteger actualPage = lround(scrollPage);
    
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
