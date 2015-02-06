//
//  MRSLBadgedBarButtonItem.h
//  Morsel
//
//  Created by Marty Trzpit on 2/5/15.
//  Copyright (c) 2015 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MRSLBadgedBarButtonItem : UIBarButtonItem

@property (nonatomic, strong) UIToolbar *toolbar;

- (void)setBadgeText:(NSString *)badgeText;

@end
