//
//  SNCollectionViewCell.m
//  SNImageViewer
//
//  Created by Narek Safaryan on 10/5/14.
//  Copyright (c) 2014 Narek Safaryan. All rights reserved.
//

#import "SNCollectionViewCell.h"

@interface SNCollectionViewCell()<UIScrollViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;

@end

@implementation SNCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        [self.scrollView setBackgroundColor:[UIColor clearColor]];
        [self.scrollView setZoomScale:1.0];
        self.scrollView.minimumZoomScale = 1.0;
        self.scrollView.maximumZoomScale = 3.0;
        self.scrollView.delegate=self;
        [self addSubview:self.scrollView];
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.imageView setBackgroundColor:[UIColor clearColor]];
        [self.imageView setAutoresizingMask:UIVIEW_AUTORESIZING_MASK_ALL];
        [self.scrollView setAutoresizingMask:UIVIEW_AUTORESIZING_MASK_ALL];
        [self.scrollView addSubview:self.imageView];
    }
    return self;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale{
    if (scrollView.zoomScale > 1.0) {
        ((UICollectionView *)(self.superview)).scrollEnabled = NO;
    }else{
        ((UICollectionView *)(self.superview)).scrollEnabled = YES;
    }
}

@end
