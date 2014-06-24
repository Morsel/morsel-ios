//
//  MRSLImageRequestable.h
//  Morsel
//
//  Created by Javier Otero on 6/24/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MRSLImageRequestable <NSObject>

@required
- (NSURLRequest *)imageURLRequestForImageSizeType:(MRSLImageSizeType)type;
- (NSData *)localImageSmall;
- (NSData *)localImageLarge;
- (NSString *)imageURL;

@end
