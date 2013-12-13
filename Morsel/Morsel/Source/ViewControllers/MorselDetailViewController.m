//
//  MorselDetailViewController.m
//  Morsel
//
//  Created by Javier Otero on 12/16/13.
//  Copyright (c) 2013 Morsel. All rights reserved.
//

#import "MorselDetailViewController.h"

#import "MRSLMorsel.h"
#import "MRSLPost.h"
#import "MRSLUser.h"
#import "ProfileImageView.h"

@interface MorselDetailViewController ()

@property (weak, nonatomic) IBOutlet UILabel *authorNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *morselTitleLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *morselScrollView;
@property (weak, nonatomic) IBOutlet UITextView *morselDescriptionTextView;

@property (weak, nonatomic) IBOutlet ProfileImageView *profileImageView;

@end

@implementation MorselDetailViewController

#pragma mark - Instance Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (_post)
    {
        self.profileImageView.user = _post.author;
        self.authorNameLabel.text = [_post.author fullName];
        self.morselTitleLabel.text = _post.title;
        self.morselDescriptionTextView.text = [(MRSLMorsel *)[_post.morsels firstObject] morselDescription];
        
        [_post.morsels enumerateObjectsUsingBlock:^(MRSLMorsel *morsel, NSUInteger idx, BOOL *stop)
         {
             if ([morsel.morselDescription length] > 0)
             {
#warning Populate text version
             }
             
             if (morsel.morselPicture)
             {
                 UIImageView *morselImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.f + (320.f * idx), 0.f, 320.f, 200.f)];
                 UIImage *morselImage = [UIImage imageWithData:morsel.morselPicture];
                 
                 morselImageView.contentMode = UIViewContentModeScaleAspectFill;
                 morselImageView.image = morselImage;
                 
                 [self.morselScrollView addSubview:morselImageView];
                 
                 [self.morselScrollView setContentSize:CGSizeMake(320.f * (idx + 1), 200.f)];
             }
         }];
    }
}

#pragma mark - Private Methods

- (IBAction)goBack:(UIBarButtonItem *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
