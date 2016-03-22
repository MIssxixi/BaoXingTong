//
//  SelectStateView.m
//  BaoXingTong
//
//  Created by yongjie_zou on 16/3/22.
//  Copyright © 2016年 yongjie_zou. All rights reserved.
//

#import "SelectStateView.h"

@interface SelectStateView ()

@property (strong, nonatomic) UIButton *allButton;
@property (strong, nonatomic) UILabel *selectedLabel;
@property (strong, nonatomic) UIButton *configButton;

@end

@implementation SelectStateView

- (instancetype)init
{
    self = [super initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.borderColor = [UIColor colorWithHexString:@"ddddd"].CGColor;
        self.layer.borderWidth = 0.5;
        [self addSubview:self.allButton];
        [self addSubview:self.configButton];
        [self addSubview:self.selectedLabel];
//        [self.selectedLabel addLeftBorderWithWidth:0.5 andColor:TX_COLOR_BORDER_LONG_EDITBOX];
//        [self.selectedLabel addRightBorderWithWidth:0.5 andColor:TX_COLOR_BORDER_LONG_EDITBOX];
        
        [self.allButton autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 0, 0) excludingEdge:ALEdgeTrailing];
        [self.allButton autoSetDimension:ALDimensionWidth toSize:SCREEN_WIDTH / 3];
        [self.selectedLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0];
        [self.selectedLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];
        [self.selectedLabel autoPinEdge:ALEdgeTrailing toEdge:ALEdgeLeading ofView:self.configButton];
        [self.selectedLabel autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:self.allButton];
        
        [self.configButton autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 0, 0) excludingEdge:ALEdgeLeading];
        [self.configButton autoSetDimension:ALDimensionWidth toSize:SCREEN_WIDTH / 3];
    }
    return self;
}

#pragma mark - set get
- (UIButton *)allButton{
    if (_allButton == nil) {
        _allButton =  [UIButton newAutoLayoutView];
        [_allButton setTitle:@"全选" forState:UIControlStateNormal];
        _allButton.imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 5);
        _allButton.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, -5);
        [_allButton setImage:[UIImage imageNamed:@"uncheck_gray"] forState:UIControlStateNormal];
        [_allButton setImage:[UIImage imageNamed:@"check_gray"] forState:UIControlStateSelected];
        _allButton.titleLabel.font = FONT(15);
        [_allButton setTitleColor:[UIColor colorWithHexString:@"999999"] forState:UIControlStateNormal];
        _allButton.layer.borderColor = [UIColor colorWithHexString:@"dddddd"].CGColor;
        _allButton.layer.borderWidth = 1;
    }
    return _allButton;
}

- (UILabel *)selectedLabel{
    if (_selectedLabel == nil) {
        _selectedLabel = ({
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
            label.font = FONT(15);
            label.textAlignment = NSTextAlignmentCenter;
            label.backgroundColor = [UIColor clearColor];
            label.textColor = [UIColor blackColor];
            label.layer.borderWidth = 1;
            label.layer.borderColor = [UIColor colorWithHexString:@"dddddd"].CGColor;
            label;
        });
        _selectedLabel.text = @"已选0个";
    }
    return _selectedLabel;
}

- (UIButton *)configButton
{
    if (_configButton == nil) {
        _configButton = ({
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setTitle:@"确认发送" forState:UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            button.titleLabel.font = FONT(15);
//            [button setBackgroundImage:[UIImage tx_imageWithColor:TX_COLOR_MAIN size:CGSizeMake(10, 10)] forState:UIControlStateNormal];
            button.backgroundColor = [UIColor colorWithHexString:@"00ccff"];
            button;
        });
    }
    return _configButton;
}

@end
