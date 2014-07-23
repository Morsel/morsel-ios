//
//  UIImagePickerController+StatusBarHidden.m
//  Morsel
//
//  Created by Marty Trzpit on 7/23/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "UIImagePickerController+StatusBarHidden.h"

@implementation UIImagePickerController (StatusBarHidden)

-(BOOL) prefersStatusBarHidden {
    return self.sourceType == UIImagePickerControllerSourceTypeCamera;
}

-(UIViewController *) childViewControllerForStatusBarHidden {
    return nil;
}

@end
