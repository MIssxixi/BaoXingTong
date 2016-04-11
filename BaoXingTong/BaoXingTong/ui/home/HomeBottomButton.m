//
//  HomeBottomButton.m
//  BaoXingTong
//
//  Created by yongjie_zou on 16/4/11.
//  Copyright © 2016年 yongjie_zou. All rights reserved.
//

#import "HomeBottomButton.h"

@interface HomeBottomButton ()

@property (nonatomic, strong, readwrite) UIButton *leftButton;
@property (nonatomic, strong, readwrite) UIButton *rightButton;

@end

@implementation HomeBottomButton

- (instancetype)init
{
    self = [super init];
    if (self) {
        {
            [self addSubview:self.leftButton];
            [self.leftButton autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeRight];
            [self.leftButton autoSetDimension:ALDimensionWidth toSize:SCREEN_WIDTH / 2.0];
            
            UIView *verticalLine = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2.0 - 1, 0, 1, BUTTON_HEIGHT)];
            verticalLine.backgroundColor = [UIColor whiteColor];
            [self.leftButton addSubview:verticalLine];
        }
        
        {
            [self addSubview:self.rightButton];
            [self.rightButton autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, SCREEN_WIDTH / 2.0, 0, 0)];
        }
    }
    return self;
}

#pragma mark - get
- (UIButton *)leftButton
{
    if (!_leftButton) {
        _leftButton = [UIButton newAutoLayoutView];
        _leftButton.backgroundColor = [UIColor colorWithHexString:@"00ccff"];
        [_leftButton setTitle:@"一键删除" forState:UIControlStateNormal];
    }
    return _leftButton;
}

- (UIButton *)rightButton
{
    if (!_rightButton) {
        _rightButton = [UIButton newAutoLayoutView];
        _rightButton.backgroundColor = [UIColor colorWithHexString:@"00ccff"];
        [_rightButton setTitle:@"删除(0)" forState:UIControlStateNormal];
        _rightButton.enabled = NO;
        _rightButton.alpha = 0.5;
    }
    return _rightButton;
}

@end
