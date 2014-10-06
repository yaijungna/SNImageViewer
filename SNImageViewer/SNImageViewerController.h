//
//  SNImageViewer.h
//  SNImageViewer
//
//  Created by Narek Safaryan on 5/11/14.
//  Copyright (c) 2014 Narek Safaryan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SNImageViewerController;
@protocol SNImageViewerDelegate <NSObject>
@optional
- (void)imageViewer:(SNImageViewerController *)imageViewer didOpenImageAtIndex:(NSInteger)imageIndex;
- (void)imageViewerDidClosed:(SNImageViewerController *)imageViewer;
- (void)imageViewer:(SNImageViewerController *)imageViewer didFinishLoadingImageAtIndex:(NSInteger)imageIndex;
@end


@protocol SNImageViewerDatasource <NSObject>
- (NSInteger)numberOfImagesInImageViewer:(SNImageViewerController *)imageViewer;
@optional
/*   One of this two methods is required   */
- (NSURL *)imageViewer:(SNImageViewerController *)imageViewer imageUrlAtIndex:(NSInteger)imageIndex;
- (UIImage *)imageViewer:(SNImageViewerController *)imageViewer imageAtIndex:(NSInteger)imageIndex;
@end


@interface SNImageViewerController : UIViewController

@property (weak, nonatomic) id<SNImageViewerDelegate> delegate;
@property (weak, nonatomic) id<SNImageViewerDatasource> datasource;
@property (nonatomic) CGRect imageViewFrameRelativeToScreen;
@property (strong, nonatomic) UIView *blockView;
@property (strong, nonatomic) UIView *senderView;
@property (nonatomic) NSInteger initialImageIndex;
@property (nonatomic) BOOL isControlsHidden;
- (void)hideControls;

@end
