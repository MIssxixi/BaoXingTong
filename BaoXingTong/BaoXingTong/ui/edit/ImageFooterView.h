//
//  ImageFooterView.h
//  BaoXingTong
//
//  Created by yongjie_zou on 16/3/17.
//  Copyright © 2016年 yongjie_zou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageFooterView : UITableViewHeaderFooterView

- (void)setImageArray:(NSArray <UIImage *> *)imageArray;

+ (CGFloat)heightWithImageArray:(NSArray <UIImage *> *)imageArray;

@end
