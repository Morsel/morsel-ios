//
//  MorselPostCollectionViewCell.m
//  Morsel
//
//  Created by Javier Otero on 12/13/13.
//  Copyright (c) 2013 Morsel. All rights reserved.
//

#import "MorselPostCollectionViewCell.h"

#import <AFNetworking/UIImageView+AFNetworking.h>

#import "JSONResponseSerializerWithData.h"
#import "ModelController.h"
#import "ProfileImageView.h"

#import "MRSLMorsel.h"
#import "MRSLPost.h"

@interface MorselPostCollectionViewCell ()

@property (nonatomic, weak) IBOutlet UIButton *likeButton;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, weak) IBOutlet UIImageView *morselImageView;

@property (nonatomic, weak) IBOutlet ProfileImageView *profileImageView;

@end

@implementation MorselPostCollectionViewCell

#pragma mark - Instance Methods

- (void)setMorsel:(MRSLMorsel *)morsel
{
    [self reset];
    
    if (_morsel != morsel)
    {
        _morsel = morsel;
        
        if (_morsel)
        {
            if (_morsel.morselPictureURL)
            {
                self.titleLabel.text = _morsel.post.title;
                self.descriptionLabel.text = morsel.morselDescription;
                
                self.profileImageView.user = _morsel.post.author;
                
                [self setLikeButtonImageForMorsel:_morsel];
                
                __weak __typeof(self)weakSelf = self;
                
                [_morselImageView setImageWithURLRequest:_morsel.morselPictureURLRequest
                                        placeholderImage:nil
                                                 success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
                 {
                     if (image)
                     {
                         weakSelf.morselImageView.image = image;
                     }
                 }
                                                 failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)
                 {
                     DDLogError(@"Unable to set Morsel Image: %@", error.userInfo);
                 }];
            }
        }
    }
}

- (void)reset
{
    [self.morselImageView cancelImageRequestOperation];
    
    self.titleLabel.text = nil;
    self.descriptionLabel.text = nil;
    self.profileImageView.user = nil;
    self.morselImageView.image = nil;
}

#pragma mark - Private Methods

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

@end
