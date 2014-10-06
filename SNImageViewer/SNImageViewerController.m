//
//  SNImageViewer.m
//  SNImageViewer
//
//  Created by Narek Safaryan on 5/11/14.
//  Copyright (c) 2014 Narek Safaryan. All rights reserved.
//


#import "SNImageViewerController.h"
#import "AppDelegate.h"
#import "SNCollectionViewCell.h"
#import "UIImageView+WebCache.h"

#define APP_DELEGATE ((SNAppDelegate *) [[UIApplication sharedApplication] delegate])
#define STATUS_BAR_VISIBLE_DURATION 5.0

@interface SNImageViewerController () <UIGestureRecognizerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>{
    CGRect _originalFrameRelativeToScreen;
    UIStatusBarStyle _oldStatusBarStyle;
    BOOL _oldStatusBarState;
    NSDate *_timerBeginDate;
    UIImageView *__imageView;
    BOOL _imageViewerOpened;
    UIToolbar *_bottomToolbar;
    UIToolbar *_topToolbar;
}

@property (strong, nonatomic) UITapGestureRecognizer *tapGesture;
@property (strong, nonatomic) UIPanGestureRecognizer *panGesture;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) UICollectionView *collectionView;

@end


@implementation SNImageViewerController

#pragma mark -
#pragma mark - Life Cycle
- (void)loadView
{
    [super loadView];
    [self setNeedsStatusBarAppearanceUpdate];
    _oldStatusBarState = [UIApplication sharedApplication].statusBarHidden;
    _oldStatusBarStyle = [[UIApplication sharedApplication] statusBarStyle];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self setNeedsStatusBarAppearanceUpdate];
    
    self.initialImageIndex = 0;
    [self.view setAutoresizingMask:UIVIEW_AUTORESIZING_MASK_ALL];
    self.blockView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.blockView setAutoresizingMask:UIVIEW_AUTORESIZING_MASK_ALL];
    [self.blockView setBackgroundColor:[UIColor blackColor]];
    self.blockView.alpha = 0.0;
    [self.view addSubview:self.blockView];
    
    UICollectionViewFlowLayout* flowLayout = [[UICollectionViewFlowLayout alloc]init];
    flowLayout.itemSize = self.view.frame.size;
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [flowLayout setMinimumLineSpacing:0.0];
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
    [self.collectionView registerClass:[SNCollectionViewCell class] forCellWithReuseIdentifier:@"ImageViewerCollectioViewCell"];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView setPagingEnabled:YES];
    [self.collectionView setMaximumZoomScale:2.0];
    [self.collectionView setMinimumZoomScale:0.5];
    [self.collectionView setBackgroundColor:[UIColor clearColor]];
    [self.collectionView setAutoresizingMask:UIVIEW_AUTORESIZING_MASK_ALL];
    [self.view addSubview:self.collectionView];
    
    _bottomToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 44.0)];
    [_bottomToolbar setBarTintColor:[UIColor colorWithRed:20/255.0 green:20/255.0 blue:20/255.0 alpha:0.5]];
    [_bottomToolbar setTintColor:[UIColor whiteColor]];
    [_bottomToolbar setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin];
    
    /*Sample button on bottom toolbar */
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:nil];
    UIBarButtonItem *bookmarksButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:nil];
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:nil];
    UIBarButtonItem *flexibleSpace1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *flexibleSpace2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    _bottomToolbar.items = [NSArray arrayWithObjects:refreshButton,flexibleSpace1, bookmarksButton, flexibleSpace2, addButton, nil];
    /**********************************/
    [self.view addSubview:_bottomToolbar];
    
    
    _topToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, -64.0, self.view.frame.size.width, 64.0)];
    [_topToolbar setBarTintColor:[UIColor colorWithRed:20/255.0 green:20/255.0 blue:20/255.0 alpha:0.5]];
    [_topToolbar setTintColor:[UIColor whiteColor]];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(didClickDone:)];
    UIBarButtonItem *flexibleSpaceTop = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(didClickedActionButton:)];
    _topToolbar.items = [NSArray arrayWithObjects:doneButton, flexibleSpaceTop, actionButton, nil];
    [_topToolbar setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin];
    [self.view addSubview:_topToolbar];
    
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.collectionView addGestureRecognizer:self.tapGesture];
    self.tapGesture.delegate = self;
    self.tapGesture.numberOfTapsRequired = 1;
    
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.view addGestureRecognizer:self.panGesture];
    self.panGesture.delegate = self;
    
    [_senderView setHidden:YES];
    CGRect windowBounds = [[UIScreen mainScreen] bounds];
    CGRect newFrame = [_senderView convertRect:windowBounds toView:nil];
    newFrame.origin = CGPointMake(newFrame.origin.x, newFrame.origin.y);
    newFrame.size = _senderView.frame.size;
    _originalFrameRelativeToScreen = newFrame;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self startTimer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)startTimer
{
    if (_timer) {
        [self invalidateTimer];
    }
    _timerBeginDate = [NSDate date];
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeTicked) userInfo:nil repeats:YES];
}

- (void)invalidateTimer
{
    [_timer invalidate];
    _timer = nil;
}

- (void)centerImageViewer
{
    SNCollectionViewCell *cell = nil;
    @try {
        cell = (SNCollectionViewCell *)[self.collectionView visibleCells][0];
    }
    @catch (NSException *exception) {
        NSLog(@"WARNING::NO VISIBLE CELLS");
    }
    [UIView animateWithDuration:0.2f delay:0.0f options:0 animations:^{
        self.blockView.alpha = 1.0;
        [cell.imageView setFrame:cell.bounds];
    } completion:^(BOOL finished) {
    }];
}

- (void)closeImageViewer
{
    [self invalidateTimer];
    self.blockView.alpha = 0.0;
    [[UIApplication sharedApplication] setStatusBarStyle:_oldStatusBarStyle];
    [[UIApplication sharedApplication] setStatusBarHidden:_oldStatusBarState];
    [self setNeedsStatusBarAppearanceUpdate];
    [self hideControls];
    UIViewController *rootViewController = [[[[UIApplication sharedApplication] windows] objectAtIndex:0] rootViewController];
    SNCollectionViewCell *cell = (SNCollectionViewCell *)[self.collectionView visibleCells][0];
    [UIView animateWithDuration:0.2f delay:0.0f options:0 animations:^{
        rootViewController.view.transform = CGAffineTransformIdentity;
        [cell.imageView setFrame:self.imageViewFrameRelativeToScreen];
    }completion:^(BOOL finished) {
        if ([self.delegate respondsToSelector:@selector(imageViewerDidClosed:)]) {
            [self.delegate imageViewerDidClosed:self];
        }
        [self removeFromParentViewController];
        [self.view removeFromSuperview];
        [_senderView setHidden:NO];
    }];
}

- (void)hideControls
{
    self.isControlsHidden = YES;
    CGRect bottomToolbarFrame = _bottomToolbar.frame;
    bottomToolbarFrame.origin.y = _bottomToolbar.superview.frame.size.height;
    
    CGRect topToolbarFrame = _topToolbar.frame;
    topToolbarFrame.origin.y -= topToolbarFrame.size.height;
    [UIView animateWithDuration:0.2f delay:0.0f options:0 animations:^{
        _bottomToolbar.frame = bottomToolbarFrame;
        _topToolbar.frame = topToolbarFrame;
    }completion:nil];
}

- (void)showControls
{
    self.isControlsHidden = NO;
    CGRect bottomToolbarFrame = _bottomToolbar.frame;
    bottomToolbarFrame.origin.y -= 44.0;
    CGRect topToolbarFrame = _topToolbar.frame;
    topToolbarFrame.origin.y = 0.0;
    [UIView animateWithDuration:0.2f delay:0.0f options:0 animations:^{
        _bottomToolbar.frame = bottomToolbarFrame;
        _topToolbar.frame = topToolbarFrame;
    }completion:nil];
}

#pragma mark -
#pragma mark - Actions

- (void)handleTap:(UITapGestureRecognizer *)tapGesture
{
    if (_isControlsHidden) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        [self showControls];
        [self startTimer];
    }else{
        [self invalidateTimer];
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        [self hideControls];
    }
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)handlePan:(UIPanGestureRecognizer *)panGesture
{
    static CGPoint previousTouchPoint;
    switch (panGesture.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            previousTouchPoint = [panGesture locationInView:self.view];
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            if (!self.isControlsHidden) {
                [self hideControls];
            }
            CGPoint currentTouchPoint = [panGesture locationInView:self.view];
            CGFloat diffY = currentTouchPoint.y - previousTouchPoint.y;
            previousTouchPoint = currentTouchPoint;
            SNCollectionViewCell *cell = (SNCollectionViewCell *)[self.collectionView visibleCells][0];
            CGRect imageViewFrame = cell.imageView.frame;
            imageViewFrame.origin.y += diffY;
            [cell.imageView setFrame:imageViewFrame];
            CGFloat alpha = 1-ABS(imageViewFrame.origin.y / (imageViewFrame.size.height/2.0));
            [self.blockView setAlpha:alpha];
        }
            break;
        case UIGestureRecognizerStateEnded:{
            SNCollectionViewCell *cell = (SNCollectionViewCell *)[self.collectionView visibleCells][0];
            CGPoint velocity = [panGesture velocityInView:self.view];
            if (abs(cell.imageView.center.y - cell.imageView.frame.size.height/2.0) >= cell.imageView.frame.size.height/5 || ABS(velocity.y) >= 1000) {
                [self closeImageViewer];
            }else{
                [self centerImageViewer];
            }
        }
            break;
        case UIGestureRecognizerStateCancelled:
        {
            [self centerImageViewer];
        }
            break;
        default:
            break;
    }
}

- (void)didClickDone:(id)sender {
    [self closeImageViewer];
}

- (void)didClickedActionButton:(id)sender
{
    NSInteger imageIndex = ((NSIndexPath *)([self.collectionView indexPathForCell:[[self collectionView] visibleCells][0]])).row;
    NSString *string = @"Share...";
    NSURL *imageUrl;
    UIImage *image;
    if ([self.datasource respondsToSelector:@selector(imageViewer:imageUrlAtIndex:)])
        imageUrl = [self.datasource imageViewer:self imageUrlAtIndex:imageIndex];
    else if ([self.delegate respondsToSelector:@selector(imageViewer:imageAtIndex:)])
        image = [self.datasource imageViewer:self imageAtIndex:imageIndex];
    NSMutableArray *activityItems = [NSMutableArray array];
    [activityItems addObject:string];
    if (imageUrl) {
        [activityItems addObject:imageUrl];
    }
    if (image) {
        [activityItems addObject:image];
    }
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems
                                      applicationActivities:nil];
    [self.navigationController presentViewController:activityViewController
                                       animated:YES
                                     completion:^{
                                         
                                     }];
}

- (void)timeTicked
{
    NSDate *currentDate = [NSDate date];
    NSTimeInterval secs = [currentDate timeIntervalSinceDate:_timerBeginDate];
    if (secs >= STATUS_BAR_VISIBLE_DURATION) {
        [self invalidateTimer];
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        [self setNeedsStatusBarAppearanceUpdate];
        [self hideControls];
    }
}

#pragma mark - UICollectionViewDatasource methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger number = [self.datasource numberOfImagesInImageViewer:self];
    return number;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%ld", (long)indexPath.row);
    static NSString *CellIdentifier = @"ImageViewerCollectioViewCell";
    SNCollectionViewCell *cell = (SNCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    if (indexPath.row == 0 && !_imageViewerOpened) {
        [cell.imageView setFrame:self.imageViewFrameRelativeToScreen];
        [UIView animateWithDuration:0.2f delay:0.0f options:0 animations:^{
            self.blockView.alpha = 1.0;
            [cell.imageView setFrame:cell.bounds];
        } completion:^(BOOL finished) {
            _imageViewerOpened = YES;
            [self showControls];
        }];
    }else{
        [cell.imageView setFrame:cell.bounds];
    }
    if ([self.datasource respondsToSelector:@selector(imageViewer:imageUrlAtIndex:)]) {
        [cell.imageView setImageWithURL:[self.datasource imageViewer:self imageUrlAtIndex:indexPath.row]];
    }else if ([self.datasource respondsToSelector:@selector(imageViewer:imageAtIndex:)]){
        UIImage *image = [self.datasource imageViewer:self imageAtIndex:indexPath.row];
        [cell.imageView setImage:image];
    }else{
        NSAssert(0, @"You must implement one of two optional methods in the SNImageViewerDatasource");
    }
    return cell;
}

#pragma mark - Flow layout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return collectionView.frame.size;
}

#pragma mark -
#pragma mark - dealloc
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    self.collectionView.delegate = nil;
    self.collectionView.dataSource = nil;
}

@end
