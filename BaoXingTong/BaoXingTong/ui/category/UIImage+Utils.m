//
//  UIImage+Utils.m
//  BaoXingTong
//
//  Created by yongjie_zou on 16/5/4.
//  Copyright © 2016年 yongjie_zou. All rights reserved.
//

#import "UIImage+Utils.h"

@implementation UIImage (Utils)

- (UIImage *)newImageWithResize:(CGSize)resize
{
    UIGraphicsBeginImageContext(resize);
    [self drawInRect:CGRectMake(0, 0, resize.width, resize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
