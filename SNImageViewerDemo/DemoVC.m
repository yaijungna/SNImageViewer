//
//  SNDemoVC.m
//  SNImageViewer
//
//  Created by Narek Safaryan on 5/11/14.
//  Copyright (c) 2014 Narek Safaryan. All rights reserved.
//

#import "DemoVC.h"
#import "SNImageViewer.h"

@interface DemoVC ()<SNImageViewerDatasource, SNImageViewerDelegate>{
    SNImageViewerController *imageViewerController;
}
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation DemoVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tap.numberOfTapsRequired = 1;
    [self.imageView addGestureRecognizer:tap];
    self.imageView.userInteractionEnabled = YES;
}

- (void)handleTap:(UITapGestureRecognizer *)tap
{
    imageViewerController = [[SNImageViewerController alloc] init];
    imageViewerController.datasource = self;
    imageViewerController.delegate = self;
    [self.imageView setupImageViewer:imageViewerController];
}

#pragma mark -
#pragma mark - SNImageViewerDatasource

- (NSInteger)numberOfImagesInImageViewer:(SNImageViewerController *)imageViewer
{
    return 20;
}

- (UIImage *)imageViewer:(SNImageViewerController *)imageViewer imageAtIndex:(NSInteger)imageIndex
{
    return [UIImage imageNamed:@"image.jpg"];
}

/* Or you can implement with web images (for that you can import SDWebimage)
 
- (NSURL *)imageViewer:(SNImageViewerController *)imageViewer imageUrlAtIndex:(NSInteger)imageIndex
{

}
*/

#pragma mark -
#pragma mark -

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{}

@end
