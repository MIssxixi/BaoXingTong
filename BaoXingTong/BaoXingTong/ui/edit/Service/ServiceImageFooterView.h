//
//  ServiceImageFooterView.h
//  BaoXingTong
//
//  Created by yongjie_zou on 16/5/12.
//  Copyright © 2016年 yongjie_zou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ServiceImageFooterView : UITableViewHeaderFooterView

@property (nonatomic, copy) void (^didDeleteAction)(NSInteger index);

- (void)setImageNames:(NSMutableArray <NSString *> *)imageNames;
//- (void)setImageArray:(NSMutableArray <UIImage *> *)imageArray;
//- (void)updateImage:(UIImage *)image AtItem:(NSInteger)item;

+ (CGFloat)heightWithImageNames:(NSArray <NSString *> *)imageName;

@end
