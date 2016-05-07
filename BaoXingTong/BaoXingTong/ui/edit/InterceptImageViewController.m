//
//  InterceptImageViewController.m
//  BaoXingTong
//
//  Created by yongjie_zou on 16/5/6.
//  Copyright © 2016年 yongjie_zou. All rights reserved.
//

#define INTERCEPT_RECT CGRectMake(25, SCREEN_HEIGHT / 2.0 - (SCREEN_WIDTH - 50) / 2.0, SCREEN_WIDTH - 50, SCREEN_WIDTH - 50)

#import "InterceptImageViewController.h"

@interface InterceptImageView : UIView

@end

@implementation InterceptImageView

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextAddEllipseInRect(ctx, INTERCEPT_RECT);
    CGContextAddRect(ctx, rect);
    UIColor *clearColor = [UIColor clearColor];
    clearColor = [clearColor colorWithAlphaComponent:0.8];
    CGContextSetFillColorWithColor(ctx, clearColor.CGColor);
    CGContextEOFillPath(ctx);
}

@end

@interface InterceptImageViewController ()

@property (nonatomic, strong) InterceptImageView *interceptImageView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImage *interceptedImage;

@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *sureButton;

@end

@implementation InterceptImageViewController

- (instancetype)initWithImage:(UIImage *)image
{
    self = [super init];
    if (self) {
        self.image = [image normalizedImage];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    self.imageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    self.imageView.image = self.image;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.imageView];
    
    
    
    self.interceptImageView = [[InterceptImageView alloc] initWithFrame:self.view.frame];
    self.interceptImageView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.interceptImageView];
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchView:)];
    UIRotationGestureRecognizer *rotationGestureRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotateView:)];
    [self.interceptImageView addGestureRecognizer:panGestureRecognizer];
    [self.interceptImageView addGestureRecognizer:pinchGestureRecognizer];
    [self.interceptImageView addGestureRecognizer:rotationGestureRecognizer];
    
    [self.view addSubview:self.cancelButton];
    [self.view addSubview:self.sureButton];
    [self.cancelButton autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:50];
    [self.cancelButton autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:30];
    [self.cancelButton autoSetDimensionsToSize:CGSizeMake(50, 50)];
    
    [self.sureButton autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:30];
    [self.sureButton autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:50];
    [self.sureButton autoSetDimensionsToSize:CGSizeMake(50, 50)];
}

- (void)panView:(UIPanGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan || sender.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [sender translationInView:self.view];
        [self.imageView setCenter:(CGPoint){self.imageView.center.x + translation.x, self.imageView.center.y + translation.y}];
        [sender setTranslation:CGPointZero inView:self.view];
    }
}

- (void)pinchView:(UIPinchGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan || sender.state == UIGestureRecognizerStateChanged) {
        self.imageView.transform = CGAffineTransformScale(self.imageView.transform, sender.scale, sender.scale);
        sender.scale = 1;
    }
}

- (void)rotateView:(UIRotationGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan || sender.state == UIGestureRecognizerStateChanged) {
        self.imageView.transform = CGAffineTransformRotate(self.imageView.transform, sender.rotation);
        [sender setRotation:0];
    }
}

- (void)tapCancelButton
{
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self.navigationController popViewControllerAnimated:YES];
    if (self.didCancel) {
        self.didCancel();
    }
}

- (void)tapSureButton
{
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    if (self.didSure) {
        self.didSure(self.interceptedImage);
    }
}

#pragma mark - get
- (UIButton *)cancelButton
{
    if (!_cancelButton) {
        _cancelButton = [UIButton newAutoLayoutView];
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(tapCancelButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

- (UIButton *)sureButton
{
    if (!_sureButton) {
        _sureButton = [UIButton newAutoLayoutView];
        [_sureButton setTitle:@"确认" forState:UIControlStateNormal];
        [_sureButton addTarget:self action:@selector(tapSureButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sureButton;
}

- (UIImage *)interceptedImage
{
    UIWindow *screenWindow = [[UIApplication sharedApplication] keyWindow];
    UIGraphicsBeginImageContext(screenWindow.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSaveGState(context);     //好像并没有什么用，得到的image的大小与屏幕大小一样
//    UIRectClip(INTERCEPT_RECT);
    [screenWindow.layer renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    image = [UIImage imageWithCGImage:CGImageCreateWithImageInRect(image.CGImage, INTERCEPT_RECT)];
    return image;
}

@end
