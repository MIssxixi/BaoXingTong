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

- (UIImage *)normalizedImage
{
    if (self.imageOrientation == UIImageOrientationUp) {
        return self;
    }
    
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    [self drawInRect:(CGRect){0, 0, self.size}];
    UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return normalizedImage;
}

@end
