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
@property (nonatomic, strong) UIButton *deleteButton;

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
        
        {
            [self.contentView addSubview:self.deleteButton];
            [self.deleteButton autoPinEdgeToSuperviewEdge:ALEdgeTop];
            [self.deleteButton autoPinEdgeToSuperviewEdge:ALEdgeRight];
            [self.deleteButton autoSetDimensionsToSize:CGSizeMake(22, 22)];
        }
    }
    return self;
}

- (void)tapDeleteButton
{
    if (self.didDeleteAction) {
        self.didDeleteAction(self);
    }
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

- (UIButton *)deleteButton
{
    if (!_deleteButton) {
        _deleteButton = [UIButton newAutoLayoutView];
        [_deleteButton setImage:[UIImage imageNamed:@"cell_cancle"] forState:UIControlStateNormal];
        _deleteButton.contentMode = UIViewContentModeScaleToFill;
        [_deleteButton sizeToFit];
        [_deleteButton addTarget:self action:@selector(tapDeleteButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteButton;
}

- (void)setImage:(UIImage *)image
{
    [self.imageView setImage:image];
}

@end
