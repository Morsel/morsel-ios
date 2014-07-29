//
// UIImage+Resize.m
//
// Created by Trevor Harmon on 8/5/09.
// Free for personal or commercial use, with or without modification.
// No warranty is expressed or implied.

#import "UIImage+Resize.h"

typedef enum {
    ALPHA = 0,
    BLUE = 1,
    GREEN = 2,
    RED = 3
} PIXELS;

@implementation UIImage (Resize)

#pragma mark - Instance Methods

// Returns a copy of this image that is cropped to the given bounds and scales it to desired dimensions.
// Accounts for imageOrientation but it can be ignored

- (UIImage *)croppedImage:(CGRect)bounds
       ignoresOrientation:(BOOL)shouldIgnoreOrientation {
    DDLogVerbose(@"Cropping Image to Bounds: CGRect(x: %f, y: %f, w: %f, h: %f)", bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.height);
    CGAffineTransform rectTransform = CGAffineTransformIdentity;

    if (!shouldIgnoreOrientation) {
        switch (self.imageOrientation) {
            case UIImageOrientationLeft:
                rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(M_PI_2), 0, -self.size.height);
                break;
            case UIImageOrientationRight:
                rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(-M_PI_2), -self.size.width, 0);
                break;
            case UIImageOrientationDown:
                rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(-M_PI), -self.size.width, -self.size.height);
                break;
            default:
                rectTransform = CGAffineTransformIdentity;
                break;
        };
        rectTransform = CGAffineTransformScale(rectTransform, self.scale, self.scale);
    }

    CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, CGRectApplyAffineTransform(bounds, rectTransform));
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef
                                                scale:self.scale
                                          orientation:self.imageOrientation];
    CGImageRelease(imageRef);
    return croppedImage;
}

// Returns a copy of this image that is squared to the thumbnail size.
// If transparentBorder is non-zero, a transparent border of the given size will be added around the edges of the thumbnail. (Adding a transparent border of at least one pixel in size has the side-effect of antialiasing the edges of the image when rotating it using Core Animation.)
- (UIImage *)thumbnailImage:(NSInteger)thumbnailSize
       interpolationQuality:(CGInterpolationQuality)quality {
    UIImage *resizedImage = [self resizedImageWithContentMode:UIViewContentModeScaleAspectFill
                                                       bounds:CGSizeMake(thumbnailSize, thumbnailSize)
                                         interpolationQuality:quality];

    // Crop out any part of the image that's larger than the thumbnail size
    // The cropped rect must be centered on the resized image
    // Round the origin points so that the size isn't altered when CGRectIntegral is later invoked
    CGRect cropRect = CGRectMake(round((resizedImage.size.width - thumbnailSize) / 2),
                                 round((resizedImage.size.height - thumbnailSize) / 2),
                                 thumbnailSize,
                                 thumbnailSize);
    UIImage *croppedImage = [resizedImage croppedImage:cropRect
                                    ignoresOrientation:YES];

    return croppedImage;
}

// Returns a rescaled copy of the image, taking into account its orientation
// The image will be scaled disproportionately if necessary to fit the bounds specified by the parameter
- (UIImage *)resizedImage:(CGSize)newSize interpolationQuality:(CGInterpolationQuality)quality {
    BOOL drawTransposed;

    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            drawTransposed = YES;
            break;
        default:
            drawTransposed = NO;
    }
    CGAffineTransform transform = [self transformForOrientation:newSize];

    return [self resizedImage:newSize
                    transform:transform
               drawTransposed:drawTransposed
         interpolationQuality:quality];
}

// Resizes the image according to the given content mode, taking into account the image's orientation
- (UIImage *)resizedImageWithContentMode:(UIViewContentMode)contentMode
                                  bounds:(CGSize)bounds
                    interpolationQuality:(CGInterpolationQuality)quality {
    CGFloat horizontalRatio = bounds.width / self.size.width;
    CGFloat verticalRatio = bounds.height / self.size.height;
    CGFloat ratio = 0.f;

    switch (contentMode) {
        case UIViewContentModeScaleAspectFill:
            ratio = MAX(horizontalRatio, verticalRatio);
            break;
        case UIViewContentModeScaleAspectFit:
            ratio = MIN(horizontalRatio, verticalRatio);
            break;
        default:
            DDLogError(@"Unsupported content mode!");
            break;
    }

    CGSize newSize = CGSizeMake(self.size.width * ratio, self.size.height * ratio);

    return [self resizedImage:newSize
         interpolationQuality:quality];
}

#pragma mark - Private Methods

// Returns a copy of the image that has been transformed using the given affine transform and scaled to the new size
// The new image's orientation will be UIImageOrientationUp, regardless of the current image's orientation
// If the new size is not integral, it will be rounded up

- (UIImage *)resizedImage:(CGSize)newSize
                transform:(CGAffineTransform)transform
           drawTransposed:(BOOL)transpose
     interpolationQuality:(CGInterpolationQuality)quality {
    NSInteger newWidth = (NSInteger)newSize.width;
    NSInteger newHeight = (NSInteger)newSize.height;

    CGRect newRect = CGRectIntegral(CGRectMake(0, 0, newWidth, newHeight));
    CGRect transposedRect = CGRectMake(0, 0, newRect.size.height, newRect.size.width);
    CGImageRef imageRef = self.CGImage;

    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    CGColorSpaceRef colorSpaceInfo = CGImageGetColorSpace(imageRef);

    unsigned long bitsPerComponent = CGImageGetBitsPerComponent(imageRef);
    unsigned long bytesPerRow = CGImageGetBytesPerRow(imageRef);
    unsigned long adjustedBytesPerRow = bitsPerComponent * newRect.size.width;

    if (bytesPerRow != adjustedBytesPerRow || bytesPerRow < adjustedBytesPerRow) {
        bytesPerRow = adjustedBytesPerRow;
    }

    if (bitmapInfo == kCGImageAlphaNone) {
        bitmapInfo = (CGBitmapInfo) kCGImageAlphaNoneSkipLast;
    }

    CGContextRef bitmap = CGBitmapContextCreate(NULL,
                                                newRect.size.width,
                                                newRect.size.height,
                                                bitsPerComponent,
                                                bytesPerRow,
                                                colorSpaceInfo,
                                                bitmapInfo);

    // Rotate and/or flip the image if required by its orientation
    CGContextConcatCTM(bitmap, transform);

    // Set the quality level to use when rescaling
    CGContextSetInterpolationQuality(bitmap, quality);

    // Draw into the context; this scales the image
    CGContextDrawImage(bitmap, transpose ? transposedRect : newRect, imageRef);

    // Get the resized image from the context and a UIImage
    CGImageRef newImageRef = CGBitmapContextCreateImage(bitmap);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];

    // Clean up
    CGContextRelease(bitmap);
    CGImageRelease(newImageRef);

    return newImage;
}

// Returns an affine transform that takes into account the image orientation when drawing a scaled image
- (CGAffineTransform)transformForOrientation:(CGSize)newSize {
    CGAffineTransform transform = CGAffineTransformIdentity;

    switch (self.imageOrientation) {
        case UIImageOrientationDown: // EXIF = 3
        case UIImageOrientationDownMirrored: // EXIF = 4
            transform = CGAffineTransformTranslate(transform, newSize.width, newSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;

        case UIImageOrientationLeft: // EXIF = 6
        case UIImageOrientationLeftMirrored: // EXIF = 5
            transform = CGAffineTransformTranslate(transform, newSize.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;

        case UIImageOrientationRight: // EXIF = 8
        case UIImageOrientationRightMirrored: // EXIF = 7
            transform = CGAffineTransformTranslate(transform, 0, newSize.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }

    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored: // EXIF = 2
        case UIImageOrientationDownMirrored: // EXIF = 4
            transform = CGAffineTransformTranslate(transform, newSize.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;

        case UIImageOrientationLeftMirrored: // EXIF = 5
        case UIImageOrientationRightMirrored: // EXIF = 7
            transform = CGAffineTransformTranslate(transform, newSize.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }

    return transform;
}

- (UIImage *)convertImageToGrayScale {
    CGFloat scale = [[UIScreen mainScreen] scale];

    CGSize size = [self size];
    int width = size.width *scale;
    int height = size.height *scale;

    // the pixels will be painted to this array
    uint32_t *pixels = (uint32_t *) malloc(width * height * sizeof(uint32_t));

    // clear the pixels so any transparency is preserved
    memset(pixels, 0, width * height * sizeof(uint32_t));

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

    // create a context with RGBA pixels
    CGContextRef context = CGBitmapContextCreate(pixels, width, height, 8, width * sizeof(uint32_t), colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);

    // paint the bitmap to our context which will fill in the pixels array
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), [self CGImage]);

    for(int y = 0; y < height; y++) {
        for(int x = 0; x < width; x++) {
            uint8_t *rgbaPixel = (uint8_t *) &pixels[y * width + x];

            // convert to grayscale using recommended method: http://en.wikipedia.org/wiki/Grayscale#Converting_color_to_grayscale
            uint32_t gray = 0.3 * rgbaPixel[RED] + 0.59 * rgbaPixel[GREEN] + 0.11 * rgbaPixel[BLUE];

            // set the pixels to gray
            rgbaPixel[RED] = gray;
            rgbaPixel[GREEN] = gray;
            rgbaPixel[BLUE] = gray;
        }
    }

    // create a new CGImageRef from our context with the modified pixels
    CGImageRef image = CGBitmapContextCreateImage(context);

    // we're done with the context, color space, and pixels
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    free(pixels);

    // make a new UIImage to return
    UIImage *resultUIImage = [UIImage imageWithCGImage:image scale:scale orientation:UIImageOrientationUp];

    // we're done with image now too
    CGImageRelease(image);

    return resultUIImage;
}

@end
