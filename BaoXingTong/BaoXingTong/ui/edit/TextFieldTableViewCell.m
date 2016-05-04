//
//  TextFieldTableViewCell.m
//  BaoXingTong
//
//  Created by yongjie_zou on 16/2/20.
//  Copyright © 2016年 yongjie_zou. All rights reserved.
//

#import "TextFieldTableViewCell.h"

@interface TextFieldTableViewCell () <UITextFieldDelegate, UITextInputTraits>

@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) UIDatePicker *datePickerView;

@property (nonatomic, strong) UIToolbar *toolbar;

@end

@implementation TextFieldTableViewCell

- (void)dealloc
{
    
}
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
            [self.rightTextField autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeLeft];
            [self.rightTextField autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.leftLabel];
        }
    }
    return self;
}



- (void)cancelDatePicker
{
    [self.rightTextField resignFirstResponder];
}

- (void)finishDatePicker
{
//    NSDateFormatter
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
//    dateFormatter.timeStyle = NSDateFormatterNoStyle;
//    dateFormatter.dateStyle = NSDateFormatterShortStyle;
    self.rightTextField.text = [dateFormatter stringFromDate:self.datePickerView.date];
    [self.rightTextField resignFirstResponder];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (self.cellStyle == TextFieldTableViewCellSelector) {
        [self.rightTextField resignFirstResponder];
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.rightTextField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (self.keyBoardDidBeginEditing && self.cellStyle == TextFieldTableViewCellKeyBoard) {
        self.keyBoardDidBeginEditing();
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (self.keyBoardDidEndEditing && (self.cellStyle == TextFieldTableViewCellKeyBoard || self.cellStyle == TextFieldTableViewCellDatePicker)) {
        self.keyBoardDidEndEditing(textField.text);
    }
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

- (TextField *)rightTextField
{
    if (!_rightTextField) {
        _rightTextField = [TextField newAutoLayoutView];
        _rightTextField.textInsets = UIEdgeInsetsMake(10, 0, 10, 0);
        _rightTextField.font = FONT(15);
        _rightTextField.textColor = COLOR_FROM_RGB(33, 33, 33, 1);
        _rightTextField.delegate = self;
//        [_rightTextField.rac_textSignal subscribeNext:^(NSString *text) {
//            
//            return ;
//        }];
    }
    return _rightTextField;
}

- (UIDatePicker *)datePickerView
{
    if (!_datePickerView) {
        _datePickerView = [[UIDatePicker alloc] init];
        _datePickerView.datePickerMode = UIDatePickerModeDate;
    }
    return _datePickerView;
}

- (UIToolbar *)toolbar
{
    if (!_toolbar) {
        _toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
        UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelDatePicker)];
        UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *finish = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(finishDatePicker)];
        [_toolbar setItems:@[cancel, space, finish]];
    }
    return _toolbar;
}

- (void)setCellStyle:(TextFieldTableViewCellStyle)cellStyle
{
    _cellStyle = cellStyle;
    if (cellStyle == TextFieldTableViewCellDatePicker) {
        self.rightTextField.inputView = self.datePickerView;
        self.rightTextField.inputAccessoryView = self.toolbar;
    }
    else if (cellStyle == TextFieldTableViewCellSelector) {
        self.rightTextField.userInteractionEnabled = NO;
    }
}
@end
