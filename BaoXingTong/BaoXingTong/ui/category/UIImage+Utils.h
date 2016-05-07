//
//  UIImage+Utils.h
//  BaoXingTong
//
//  Created by yongjie_zou on 16/5/4.
//  Copyright © 2016年 yongjie_zou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Utils)

- (UIImage *)newImageWithResize:(CGSize)resize;

- (UIImage *)normalizedImage;       //让图片已正常的方向显示

@end
