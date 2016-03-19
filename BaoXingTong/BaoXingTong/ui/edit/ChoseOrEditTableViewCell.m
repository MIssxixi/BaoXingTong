//
//  ChoseOrEditTableViewCell.m
//  BaoXingTong
//
//  Created by yongjie_zou on 16/3/14.
//  Copyright © 2016年 yongjie_zou. All rights reserved.
//

#import "ChoseOrEditTableViewCell.h"

@interface ChoseOrEditTableViewCell() <UITextFieldDelegate, UITextInputTraits>

@property (nonatomic, strong) UIButton *indicatorButton;

@end

@implementation ChoseOrEditTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        {
            [self.contentView addSubview:self.leftLabel];
            [self.leftLabel autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, PADDING_LR, 0, 0) excludingEdge:ALEdgeRight];
            [self.leftLabel autoSetDimension:ALDimensionWidth toSize:100];
        }
        
        {
            [self.contentView addSubview:self.rightTextField];
            [self.rightTextField autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.contentView];
            [self.rightTextField autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.contentView];
            [self.rightTextField autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.leftLabel];
        }
        
        {
            [self.contentView addSubview:self.indicatorButton];
            [self.rightTextField autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:self.indicatorButton];
            [self.indicatorButton autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeLeft];
            [self.indicatorButton autoSetDimension:ALDimensionWidth toSize:30];
        }
    }
    
    return self;
}

- (void)tapIndicator
{
    if (self.didTapIndicator) {
        self.didTapIndicator();
    }
    return;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (self.keyBoardDidEndEditing) {
        self.keyBoardDidEndEditing(textField.text);
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.rightTextField resignFirstResponder];
    return YES;
}

#pragma mark - get
- (UILabel *)leftLabel
{
    if (!_leftLabel) {
        _leftLabel = [UILabel newAutoLayoutView];
        _leftLabel.font = FONT(15);
        _leftLabel.textColor = COLOR_FROM_RGB(99, 99, 99, 1);
    }
    return _leftLabel;
}

- (UITextField *)rightTextField
{
    if (!_rightTextField) {
        _rightTextField = [UITextField newAutoLayoutView];
        _rightTextField.font = FONT(15);
        _rightTextField.textColor = COLOR_FROM_RGB(33, 33, 33, 1);
        _rightTextField.delegate = self;
    }
    return _rightTextField;
}

- (void)setKeyboardType:(UIKeyboardType)keyboardType
{
    self.rightTextField.keyboardType = keyboardType;
}

- (UIButton *)indicatorButton
{
    if (!_indicatorButton) {
        _indicatorButton = [UIButton newAutoLayoutView];
        [_indicatorButton setImage:[UIImage imageNamed:@"cell_indicator"] forState:UIControlStateNormal];
        _indicatorButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
        _indicatorButton.backgroundColor = [UIColor redColor];
        [_indicatorButton addTarget:self action:@selector(tapIndicator) forControlEvents:UIControlEventTouchUpInside];
    }
    return _indicatorButton;
}

@end
