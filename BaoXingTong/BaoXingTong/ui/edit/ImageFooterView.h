//
//  ImageFooterView.h
//  BaoXingTong
//
//  Created by yongjie_zou on 16/3/17.
//  Copyright © 2016年 yongjie_zou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageFooterView : UITableViewHeaderFooterView

@property (nonatomic, copy) void (^didDeleteAction)(NSInteger index);

- (void)setImageNames:(NSMutableArray <NSString *> *)imageNames;        //用于取本地图片，需要随时维护，编辑保单时可能会删除一些图片
- (void)setImageArray:(NSMutableArray <UIImage *> *)imageArray;
- (void)updateImage:(UIImage *)image AtItem:(NSInteger)item;

+ (CGFloat)heightWithImageArray:(NSArray <UIImage *> *)imageArray;

@end
