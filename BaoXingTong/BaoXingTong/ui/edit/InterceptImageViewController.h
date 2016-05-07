//
//  InterceptImageViewController.h
//  BaoXingTong
//
//  Created by yongjie_zou on 16/5/6.
//  Copyright © 2016年 yongjie_zou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InterceptImageViewController : UIViewController

@property (nonatomic, copy) void (^didCancel)();
@property (nonatomic, copy) void (^didSure)(UIImage *image);

- (instancetype)initWithImage:(UIImage *)image;

@end
