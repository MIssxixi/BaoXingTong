//
//  LoginViewController.m
//  BaoXingTong
//
//  Created by yongjie_zou on 16/4/25.
//  Copyright © 2016年 yongjie_zou. All rights reserved.
//

#import "LoginViewController.h"
#import "GetVerificationCodeViewController.h"
#import "RegisterViewController.h"
#import "HomeViewController.h"
#import "TextField.h"
#import "TipView.h"
#import "DataManager.h"
#import <SMS_SDK/SMSSDK.h>
#import "EditGuaranteeSlipViewController.h"
#import "GuaranteeSlipModel.h"

#import "ForgetPasswordGetVerificationCodeViewController.h"

@interface LoginViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UITextField *domainField;
@property (nonatomic, strong) TextField *nameField;
@property (nonatomic, strong) TextField *passwordField;
@property (nonatomic, strong) UIButton *loginButton;
@property (nonatomic, strong) UIButton *registerButton;
@property (nonatomic, strong) UIButton *forgetButton;

@end

@implementation LoginViewController

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configUI];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction)];
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

- (void)tapGestureAction
{
    //If target is nil, the app sends the message to the first responder, from whence it progresses up the responder chain until it is handled.
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}

- (void)configUI
{
    self.view.backgroundColor = [UIColor colorWithHexString:@"f0f0f0"];
    
    [self.view addSubview:self.imageView];
    [self.imageView autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [self.imageView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:68];
    [self.imageView autoSetDimensionsToSize:CGSizeMake(120, 120)];
    
    [self.view addSubview:self.domainField];
    [self.domainField autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.imageView withOffset:48];
    [self.domainField autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:15];
    [self.domainField autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:15];
    [self.domainField autoSetDimension:ALDimensionHeight toSize:44];
    
    [self.view addSubview:self.nameField];
//    [self.nameField autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [self.nameField autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.domainField];
    [self.nameField autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:15];
    [self.nameField autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:15];
    [self.nameField autoSetDimension:ALDimensionHeight toSize:44];
    
    [self.view addSubview:self.passwordField];
//    [self.passwordField autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [self.passwordField autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.nameField];
    [self.passwordField autoPinEdge:ALEdgeLeading toEdge:ALEdgeLeading ofView:self.nameField];
    [self.passwordField autoPinEdge:ALEdgeTrailing toEdge:ALEdgeTrailing ofView:self.nameField];
    [self.passwordField autoSetDimension:ALDimensionHeight toSize:44];
    
    [self.view addSubview:self.loginButton];
    [self.loginButton autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [self.loginButton autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.passwordField withOffset:10];
    [self.loginButton autoPinEdge:ALEdgeLeading toEdge:ALEdgeLeading ofView:self.nameField];
    [self.loginButton autoPinEdge:ALEdgeTrailing toEdge:ALEdgeTrailing ofView:self.nameField];
    [self.loginButton autoSetDimension:ALDimensionHeight toSize:44];
    
    [self.view addSubview:self.forgetButton];
    [self.forgetButton autoPinEdge:ALEdgeTrailing toEdge:ALEdgeTrailing ofView:self.loginButton];
    [self.forgetButton autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.loginButton withOffset:10];
    [self.forgetButton autoSetDimensionsToSize:CGSizeMake(60, 31)];
    
    [self.view addSubview:self.registerButton];
    [self.registerButton autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [self.registerButton autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.loginButton withOffset:30];
}

- (void)checkDomain
{
    BOOL canOpen = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:self.domainField.text]];
    if (self.domainField.text.length > 0) {
        if (!canOpen) {
            [TipView show:@"无法打开的域名"];
            return;
        }
        [DataServiceManager sharedManager].domainName = self.domainField.text;
        [DataServiceManager sharedManager].isUsingService = YES;
    }
    else
    {
        [DataServiceManager sharedManager].isUsingService = NO;
    }
}

- (void)login
{
    if (0 == self.nameField.text.length || 0 == self.passwordField.text.length) {
        [TipView show:@"用户名和密码不能为空"];
        return;
    }
    
    [self checkDomain];
    
    if ([DataServiceManager sharedManager].isUsingService) {
        [LoadingView showMessage:@"正在登录" toView:self.view];
        [[DataServiceManager sharedManager] loginWithName:self.nameField.text password:self.passwordField.text response:^(ServiceResponseModel *responseModel) {
            [LoadingView hide];
            
            if (responseModel.errorMessage.length) {
                [TipView show:responseModel.errorMessage];
            }
            else
            {
                HomeViewController *homeViewController = [[HomeViewController alloc] init];
                UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:homeViewController];
                [UIApplication sharedApplication].windows[0].rootViewController = navi;
            }
        }];
        return;
    }
    
    BOOL loginStatus = [[DataManager sharedManager] loginWithUserName:self.nameField.text password:self.passwordField.text];
    if (loginStatus) {
        HomeViewController *homeViewController = [[HomeViewController alloc] init];
        UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:homeViewController];
        [UIApplication sharedApplication].windows[0].rootViewController = navi;
    }
    else if (![DataServiceManager sharedManager].isUsingService)
    {
        [TipView show:@"登录名或密码错误"];
    }
}

- (void)registerAccount
{
    [self checkDomain];
    
    GetVerificationCodeViewController *registerViewController = [[GetVerificationCodeViewController alloc] init];
    [self.navigationController pushViewController:registerViewController animated:YES];
}

- (void)forgetPassword
{
    [self checkDomain];
    
    ForgetPasswordGetVerificationCodeViewController *vc = [[ForgetPasswordGetVerificationCodeViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (UILabel *)leftLabel:(NSString *)title
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = title;
    label.textColor = [UIColor colorWithHexString:@"6d6d6d"];
    label.font = FONT(15);
    label.backgroundColor = [UIColor clearColor];
    return label;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self login];
    return YES;
}

#pragma mark - get
- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [UIImageView newAutoLayoutView];
        _imageView.image = [UIImage imageNamed:@"Icon-60"];
    }
    return _imageView;
}

- (UITextField *)domainField
{
    if (!_domainField) {
        _domainField = [UITextField newAutoLayoutView];
        _domainField.backgroundColor = [UIColor whiteColor];
        _domainField.font = FONT(15);
        _domainField.delegate = self;
        _domainField.placeholder = @"不输入则本地存储";
        _domainField.leftView = [self leftLabel:@"域    名"];
        _domainField.leftViewMode = UITextFieldViewModeAlways;
        _domainField.keyboardType = UIKeyboardTypeAlphabet;
        _domainField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _domainField.layer.borderColor = [UIColor colorWithHexString:@"dddddd"].CGColor;
        _domainField.layer.borderWidth = 0.5;
    }
    return _domainField;
}

- (UITextField *)nameField
{
    if (!_nameField) {
        _nameField = [TextField newAutoLayoutView];
        _nameField.textInsets = UIEdgeInsetsMake(10, 0, 10, 0);
        _nameField.backgroundColor = [UIColor whiteColor];
        _nameField.font = FONT(15);
        _nameField.delegate = self;
        _nameField.leftView = [self leftLabel:@"用户名"];
        _nameField.leftViewMode = UITextFieldViewModeAlways;
        _nameField.keyboardType = UIKeyboardTypeAlphabet;
        _nameField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _nameField.layer.borderColor = [UIColor colorWithHexString:@"dddddd"].CGColor;
        _nameField.layer.borderWidth = 0.5;
    }
    return _nameField;
}

- (UITextField *)passwordField
{
    if (!_passwordField) {
        _passwordField = [TextField newAutoLayoutView];
        _passwordField.textInsets = UIEdgeInsetsMake(10, 0, 10, 0);
        _passwordField.backgroundColor = [UIColor whiteColor];
        _passwordField.font = FONT(15);
        _passwordField.delegate = self;
        _passwordField.leftView = [self leftLabel:@"密    码"];
        _passwordField.secureTextEntry = YES;
        _passwordField.leftViewMode = UITextFieldViewModeAlways;
        _passwordField.keyboardType = UIKeyboardTypeAlphabet;
        _passwordField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _passwordField.layer.borderColor = [UIColor colorWithHexString:@"dddddd"].CGColor;
        _passwordField.layer.borderWidth = 0.5;
    }
    return _passwordField;
}

- (UIButton *)loginButton
{
    if (!_loginButton) {
        _loginButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_loginButton setTitle:@"登录" forState:UIControlStateNormal];
        [_loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _loginButton.backgroundColor = [UIColor colorWithHexString:@"00ccff"];
        [_loginButton addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    }
    return _loginButton;
}

- (UIButton *)registerButton
{
    if (!_registerButton) {
        _registerButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_registerButton setTitle:@"注册" forState:UIControlStateNormal];
        [_registerButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        _registerButton.backgroundColor = [UIColor clearColor];
        [_registerButton addTarget:self action:@selector(registerAccount) forControlEvents:UIControlEventTouchUpInside];
    }
    return _registerButton;
}

- (UIButton *)forgetButton
{
    if (!_forgetButton) {
        _forgetButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_forgetButton setTitle:@"忘记密码" forState:UIControlStateNormal];
        [_forgetButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        _forgetButton.titleLabel.font = FONT(12);
        _forgetButton.backgroundColor = [UIColor clearColor];
        [_forgetButton addTarget:self action:@selector(forgetPassword) forControlEvents:UIControlEventTouchUpInside];
    }
    return _forgetButton;
}

- (void)dealloc
{
    
}

@end
