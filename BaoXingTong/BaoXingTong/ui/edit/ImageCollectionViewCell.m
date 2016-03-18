//
//  ImageCollectionViewCell.m
//  BaoXingTong
//
//  Created by yongjie_zou on 16/3/17.
//  Copyright © 2016年 yongjie_zou. All rights reserved.
//

#import "ImageCollectionViewCell.h"

@interface ImageCollectionViewCell ()

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation ImageCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        {
            [self.contentView addSubview:self.imageView];
            [self.imageView autoPinEdgesToSuperviewEdges];
        }
        
    }
    return self;
}


#pragma mark - get set
- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [UIImageView newAutoLayoutView];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        _imageView.backgroundColor = [UIColor clearColor];
    }
    return _imageView;
}

- (void)setImage:(UIImage *)image
{
    [self.imageView setImage:image];
}

@end
