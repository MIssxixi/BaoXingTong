//
//  verificationViewController.m
//  BaoXingTong
//
//  Created by yongjie_zou on 16/4/26.
//  Copyright © 2016年 yongjie_zou. All rights reserved.
//

#import "VerificationViewController.h"
#import "RegisterViewController.h"
#import "TextField.h"
#import "TipView.h"
#import <SMS_SDK/SMSSDK.h>

@interface VerificationViewController ()

@property (nonatomic, readwrite, copy) NSString *phoneNumber;
@property (nonatomic, readwrite, strong) TextField *verificationCodeTextField;
@property (nonatomic, strong) UIButton *nextButton;

@end

@implementation VerificationViewController

- (instancetype)initWithPhone:(NSString *)phone
{
    self = [super init];
    self.phoneNumber = phone;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = NO;
    self.title = @"填写验证码";
    [self configUI];
    
    [self.verificationCodeTextField becomeFirstResponder];
}

- (void)configUI
{
    self.view.backgroundColor = [UIColor colorWithHexString:@"f0f0f0"];
    
    [self.view addSubview:self.verificationCodeTextField];
    [self.verificationCodeTextField autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:80];
    [self.verificationCodeTextField autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:15];
    [self.verificationCodeTextField autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:15];
    [self.verificationCodeTextField autoSetDimension:ALDimensionHeight toSize:44];
    
    [self.view addSubview:self.nextButton];
    [self.nextButton autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [self.nextButton autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:15];
    [self.nextButton autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:15];
    [self.nextButton autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.verificationCodeTextField withOffset:20];
    [self.nextButton autoSetDimension:ALDimensionHeight toSize:44];
}

- (void)nextAction
{
    [LoadingView showMessage:@"正在验证短信" toView:self.view];
    WS(weakSelf)
    [SMSSDK commitVerificationCode:self.verificationCodeTextField.text phoneNumber:self.phoneNumber zone:@"86" result:^(NSError *error) {
        [LoadingView hide];
        if (error) {
            [TipView show:[error.userInfo valueForKey:@"commitVerificationCode"]];
        }
        else
        {
            [TipView show:@"验证成功"];
            RegisterViewController *registerViewController = [[RegisterViewController alloc] initWithPhoneNumber:weakSelf.phoneNumber];
            [weakSelf.navigationController pushViewController:registerViewController animated:YES];
        }
    }];
}

#pragma mark - get
- (UITextField *)verificationCodeTextField
{
    if (!_verificationCodeTextField) {
        _verificationCodeTextField = [TextField newAutoLayoutView];
        _verificationCodeTextField.textInsets = UIEdgeInsetsMake(12, 0, 12, 0);
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"验证码";
        label.textColor = [UIColor colorWithHexString:@"6d6d6d"];
        label.backgroundColor = [UIColor clearColor];
        _verificationCodeTextField.leftView = label;
        _verificationCodeTextField.leftViewMode = UITextFieldViewModeAlways;
        _verificationCodeTextField.backgroundColor = [UIColor whiteColor];
        [_verificationCodeTextField setKeyboardType:UIKeyboardTypePhonePad];
        _verificationCodeTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    return _verificationCodeTextField;
}

- (UIButton *)nextButton
{
    if (!_nextButton) {
        _nextButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_nextButton setTitle:@"下一步" forState:UIControlStateNormal];
        [_nextButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        _nextButton.backgroundColor = [UIColor colorWithHexString:@"00ccff"];
        [_nextButton addTarget:self action:@selector(nextAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nextButton;
}


@end
