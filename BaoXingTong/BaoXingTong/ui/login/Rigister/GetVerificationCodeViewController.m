//
//  RegisterViewController.m
//  BaoXingTong
//
//  Created by yongjie_zou on 16/4/26.
//  Copyright © 2016年 yongjie_zou. All rights reserved.
//

#import "GetVerificationCodeViewController.h"
#import "VerificationViewController.h"
#import "TextField.h"
#import "TipView.h"
#import <SMS_SDK/SMSSDK.h>

@interface GetVerificationCodeViewController ()

@property (nonatomic, readwrite, strong) TextField *phoneField;
@property (nonatomic, strong) UIButton *registerButton;

@end

@implementation GetVerificationCodeViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
//    [self.navigationController setNavigationBarHidden:NO];    //会导致UITextField显示出错，原因不明！！！
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"验证手机号码";
    [self configUI];
    
    [self.phoneField becomeFirstResponder];
}

- (void)configUI
{
    self.view.backgroundColor = [UIColor colorWithHexString:@"f0f0f0"];
    
    [self.view addSubview:self.phoneField];
//    [self.phoneField autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [self.phoneField autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:80];
    [self.phoneField autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:15];
    [self.phoneField autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:15];
    [self.phoneField autoSetDimension:ALDimensionHeight toSize:44];
    
    [self.view addSubview:self.registerButton];
//    [self.registerButton autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [self.registerButton autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:15];
    [self.registerButton autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:15];
    [self.registerButton autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.phoneField withOffset:20];
    [self.registerButton autoSetDimension:ALDimensionHeight toSize:44];
}

- (void)nextAction
{
    [LoadingView showMessage:@"正在发送短信" toView:self.view];
    WS(weakSelf)
    [SMSSDK getVerificationCodeByMethod:SMSGetCodeMethodSMS phoneNumber:self.phoneField.text zone:@"86" customIdentifier:nil result:^(NSError *error) {
        [LoadingView hide];
        if (error) {
            [TipView show:[error.userInfo valueForKey:@"getVerificationCode"]];
        }
        else
        {
            [TipView show:@"短信发送成功"];
            VerificationViewController *verificationViewController = [[VerificationViewController alloc] initWithPhone:weakSelf.phoneField.text];
            [weakSelf.navigationController pushViewController:verificationViewController animated:YES];
        }
    }];
}

#pragma mark - get
- (UITextField *)phoneField
{
    if (!_phoneField) {
        _phoneField = [TextField newAutoLayoutView];
        _phoneField.textInsets = UIEdgeInsetsMake(12, 0, 12, 0);
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"+86";
        label.textColor = [UIColor colorWithHexString:@"6d6d6d"];
        label.backgroundColor = [UIColor clearColor];
        _phoneField.leftView = label;
        _phoneField.leftViewMode = UITextFieldViewModeAlways;
        _phoneField.backgroundColor = [UIColor whiteColor];
        [_phoneField setKeyboardType:UIKeyboardTypePhonePad];
        _phoneField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    return _phoneField;
}

- (UIButton *)registerButton
{
    if (!_registerButton) {
        _registerButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_registerButton setTitle:@"下一步" forState:UIControlStateNormal];
        [_registerButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        _registerButton.backgroundColor = [UIColor colorWithHexString:@"00ccff"];
        [_registerButton addTarget:self action:@selector(nextAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _registerButton;
}

- (void)dealloc
{
    
}

@end
