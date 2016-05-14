//
//  ImageCollectionViewCell.h
//  BaoXingTong
//
//  Created by yongjie_zou on 16/3/17.
//  Copyright © 2016年 yongjie_zou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, copy) NSString *imageName;

@property (nonatomic, copy) void (^didDeleteAction)(UICollectionViewCell *cell);

@end
