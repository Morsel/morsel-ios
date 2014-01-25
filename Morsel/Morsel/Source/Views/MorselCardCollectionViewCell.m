//
//  MorselCardCollectionViewCell.m
//  Morsel
//
//  Created by Javier Otero on 12/13/13.
//  Copyright (c) 2013 Morsel. All rights reserved.
//

#import "MorselCardCollectionViewCell.h"

#import "GCPlaceholderTextView.h"

#import "MRSLMorsel.h"

@interface MorselCardCollectionViewCell ()

<
UITextViewDelegate
>

@property (weak, nonatomic) IBOutlet UIButton *addMediaButton;
@property (weak, nonatomic) IBOutlet UIImageView *mediaImageView;

@property (weak, nonatomic) IBOutlet GCPlaceholderTextView *placeholderTextView;

@end

@implementation MorselCardCollectionViewCell

#pragma mark - Instance Methods

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.placeholderTextView.placeholder = @"Tell us what's cookin?";
}

- (void)updateMedia:(UIImage *)media
{
    self.addMediaButton.hidden = YES;
    self.mediaImageView.hidden = NO;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^
    {
        UIImage *thumbnail = [media thumbnailImage:50.f
                              interpolationQuality:kCGInterpolationHigh];
        
        dispatch_async(dispatch_get_main_queue(), ^
        {
            self.mediaImageView.image = thumbnail;
        });
        
        UIImage *picture = [media resizedImageWithContentMode:UIViewContentModeScaleAspectFill
                                                       bounds:CGSizeMake(320.f, 200.f)
                                         interpolationQuality:kCGInterpolationHigh];
        
        self.morsel.morselPicture = UIImageJPEGRepresentation(picture, 1.f);
        self.morsel.morselThumb = UIImageJPEGRepresentation(thumbnail, .5f);
    });
   
}

- (void)setMorsel:(MRSLMorsel *)morsel
{
    if (_morsel != morsel)
    {
        [self reset];
        
        _morsel = morsel;
        
        if (_morsel.morselPicture)
        {
            self.addMediaButton.hidden = YES;
            
            self.mediaImageView.hidden = NO;
            self.mediaImageView.image = [UIImage imageWithData:_morsel.morselThumb];
        }
        
        if (_morsel.morselDescription)
        {
            self.placeholderTextView.text = _morsel.morselDescription;
        }
    }
}

- (void)reset
{
    self.addMediaButton.hidden = NO;
    
    self.mediaImageView.hidden = YES;
    self.mediaImageView.image = nil;
    
    self.placeholderTextView.text = @"";
}

#pragma mark - Private Methods

- (IBAction)addMedia
{
    if ([self.delegate respondsToSelector:@selector(morselCardDidSelectAddMedia:)])
    {
        [self.delegate morselCardDidSelectAddMedia:self];
    }
}

- (IBAction)deleteMorsel
{
    if ([self.delegate respondsToSelector:@selector(morselCardShouldDelete:)])
    {
        [self.delegate morselCardShouldDelete:self];
    }
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([self.delegate respondsToSelector:@selector(morselCardDidBeginEditing:)])
    {
        [self.delegate morselCardDidBeginEditing:self];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    self.morsel.morselDescription = self.placeholderTextView.text;
    
    if ([self.delegate respondsToSelector:@selector(morselCard:didUpdateDescription:)])
    {
        [self.delegate morselCard:self didUpdateDescription:self.placeholderTextView.text];
    }
}

@end
