//
//  UIImageView+SNImageViewer.m
//  SNImageViewer
//
//  Created by Narek Safaryan on 10/5/14.
//  Copyright (c) 2014 Narek Safaryan. All rights reserved.
//

#import "UIImageView+SNImageViewer.h"

@implementation UIImageView(SNImageViewer)

- (void)setupImageViewer:(SNImageViewerController *)imageViewerController;
{
    imageViewerController.senderView = self;
    UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    UIViewController *rootViewController = [window rootViewController];
    
    CGRect windowBounds = [[UIScreen mainScreen] bounds];
    CGRect imageViewFrameRelativeToScreen = [self convertRect:windowBounds toView:nil];
    imageViewFrameRelativeToScreen.origin = CGPointMake(imageViewFrameRelativeToScreen.origin.x, imageViewFrameRelativeToScreen.origin.y);
    imageViewFrameRelativeToScreen.size = self.frame.size;
    imageViewerController.imageViewFrameRelativeToScreen = imageViewFrameRelativeToScreen;
    
    [[[[UIApplication sharedApplication] windows] objectAtIndex:0] addSubview:imageViewerController.view];
    [rootViewController addChildViewController:imageViewerController];
    [imageViewerController didMoveToParentViewController:rootViewController];
    CGAffineTransform transf = CGAffineTransformIdentity;
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        CGAffineTransform rootControllerTransform = CGAffineTransformScale(transf, 0.95f, 0.95f);
        [rootViewController.view setTransform:rootControllerTransform];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
        }];
    }];
    [UIView animateWithDuration:0.4 animations:^{
        imageViewerController.blockView.alpha = 1.0;
    }];
}

@end