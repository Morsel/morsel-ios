//
//  MorselDetailPanelViewController.m
//  Morsel
//
//  Created by Javier Otero on 1/24/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MorselDetailPanelViewController.h"

#import <AFNetworking/UIImageView+AFNetworking.h>

#import "JSONResponseSerializerWithData.h"
#import "ModelController.h"

#import "MRSLMorsel.h"

@interface MorselDetailPanelViewController ()

<
UIScrollViewDelegate
>

@property (weak, nonatomic) IBOutlet UIButton *addCommentButton;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIImageView *morselImageView;
@property (weak, nonatomic) IBOutlet UILabel *morselDescriptionLabel;

@end

@implementation MorselDetailPanelViewController

- (void)setMorsel:(MRSLMorsel *)morsel
{
    if (_morsel != morsel)
    {
        _morsel = morsel;
    }
    
    if ([_morsel.morselDescription length] > 0)
    {
#warning Populate text version
    }
    
    if (_morsel.morselDescription)
    {
        _morselDescriptionLabel.text = _morsel.morselDescription;
    }
    else
    {
        _morselDescriptionLabel.text = @"No Description";
        _morselDescriptionLabel.textColor = [UIColor morselUserInterface];
    }
    
    if (_morsel.morselPictureURL)
    {
        if (_morsel.morselPicture)
        {
            UIImage *morselImage = [UIImage imageWithData:_morsel.morselPicture];
            _morselImageView.image = morselImage;
        }
        
        if (_morsel.morselPictureURL &&
            !_morsel.morselPicture)
        {
            __weak UIImageView *weakImageView = _morselImageView;
            
            [_morselImageView setImageWithURLRequest:[_morsel morselPictureURLRequestForImageSizeType:MorselImageSizeTypeCropped]
                                    placeholderImage:nil
                                             success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
             {
                 if (image)
                 {
                     __strong UIImageView *strongImageView = weakImageView;
                     strongImageView.image = image;
                 }
             }
                                             failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)
             {
                 DDLogError(@"Unable to set Morsel Image in ScrollView: %@", error.userInfo);
             }];
        }
    }
    
    [self setLikeButtonImageForMorsel:_morsel];
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
    UIImage *likeImage = [UIImage imageNamed:morsel.likedValue ? @"icon-like-active" : @"icon-like-inactive"];
    
    [_likeButton setImage:likeImage
                 forState:UIControlStateNormal];
    
    _likeButton.enabled = YES;
}

#pragma mark - UIScrollViewDelegate Methods



@end
