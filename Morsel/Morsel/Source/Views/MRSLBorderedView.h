//
//  MRSLBorderedView.h
//  Morsel
//
//  Created by Marty Trzpit on 7/31/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MRSLBorderedView : UIView

//  User Defined NSString in IB. Can be any combo of: North|South|East|West
@property (nonatomic, assign) NSString *borderDirections;

@end
