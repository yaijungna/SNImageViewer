//
//  SNCollectionViewCell.h
//  SNImageViewer
//
//  Created by Narek Safaryan on 10/5/14.
//  Copyright (c) 2014 Narek Safaryan. All rights reserved.
//

#import <UIKit/UIKit.h>

#define UIVIEW_AUTORESIZING_MASK_ALL UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin

@interface SNCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) UIImageView *imageView;

@end
