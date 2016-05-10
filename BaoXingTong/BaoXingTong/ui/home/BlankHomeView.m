//
//  BlankHomeView.m
//  BaoXingTong
//
//  Created by yongjie_zou on 16/5/7.
//  Copyright © 2016年 yongjie_zou. All rights reserved.
//

#import "BlankHomeView.h"

@interface BlankHomeView ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIButton *button;

@end

@implementation BlankHomeView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor colorWithHexString:@"f0f0f0"];
        [self addSubview:self.imageView];
        [self.imageView autoAlignAxisToSuperviewAxis:ALAxisVertical];
        [self.imageView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:180];
        [self.imageView autoSetDimensionsToSize:CGSizeMake(120, 120)];
        
        [self addSubview:self.label];
        [self.label autoAlignAxisToSuperviewAxis:ALAxisVertical];
        [self.label autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.imageView withOffset:20];
        
        [self addSubview:self.button];
        [self.button autoAlignAxisToSuperviewAxis:ALAxisVertical];
        [self.button autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.label withOffset:20];
        [self.button autoSetDimension:ALDimensionWidth toSize:100];
    }
    return self;
}

- (void)onButton
{
    if (self.tapButton) {
        self.tapButton();
    }
}

#pragma mark - get
- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [UIImageView newAutoLayoutView];
        _imageView.image = [UIImage imageNamed:@"Icon-60"];
        _imageView.layer.cornerRadius = 60;
        _imageView.clipsToBounds = YES;
    }
    return _imageView;
}

- (UILabel *)label
{
    if (!_label) {
        _label = [UILabel newAutoLayoutView];
        _label.text = @"您还没有保单，快去新建保单吧";
        _label.textColor = [UIColor colorWithHexString:@"333333"];
    }
    return _label;
}

- (UIButton *)button
{
    if (!_button) {
        _button = [UIButton newAutoLayoutView];
        [_button setTitle:@"新建" forState:UIControlStateNormal];
        _button.backgroundColor = [UIColor colorWithHexString:@"00ccff"];
        _button.layer.cornerRadius = 4;
        _button.clipsToBounds = YES;
        [_button addTarget:self action:@selector(onButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return _button;
}

@end
