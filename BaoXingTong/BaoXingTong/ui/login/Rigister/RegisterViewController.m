//
//  RegisterViewController.m
//  BaoXingTong
//
//  Created by yongjie_zou on 16/4/26.
//  Copyright © 2016年 yongjie_zou. All rights reserved.
//

#import "RegisterViewController.h"
#import "HomeViewController.h"
#import "DataManager.h"
#import "UserModel.h"
#import "TextField.h"
#import "TipView.h"

@interface RegisterViewController ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UserModel *userModel;
@property (nonatomic, strong) TextField *nameField;
@property (nonatomic, strong) TextField *passwordField;
@property (nonatomic, strong) UIButton *confirmButton;

@end

@implementation RegisterViewController

- (instancetype)initWithPhoneNumber:(NSString *)phoneNumber
{
    self = [super init];
    if (self) {
        self.userModel.phone = phoneNumber;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"注册";
    
    [self configUI];
}

- (void)configUI
{
    self.view.backgroundColor = [UIColor colorWithHexString:@"f0f0f0"];
    
    [self.view addSubview:self.imageView];
    [self.imageView autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [self.imageView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:68];
    [self.imageView autoSetDimensionsToSize:CGSizeMake(120, 120)];
    
    [self.view addSubview:self.nameField];
    [self.nameField autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [self.nameField autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.imageView withOffset:48];
    [self.nameField autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:15];
    [self.nameField autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:15];
    [self.nameField autoSetDimension:ALDimensionHeight toSize:44];
    
    [self.view addSubview:self.passwordField];
    [self.passwordField autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [self.passwordField autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.nameField];
    [self.passwordField autoPinEdge:ALEdgeLeading toEdge:ALEdgeLeading ofView:self.nameField];
    [self.passwordField autoPinEdge:ALEdgeTrailing toEdge:ALEdgeTrailing ofView:self.nameField];
    [self.passwordField autoSetDimension:ALDimensionHeight toSize:44];
    
    [self.view addSubview:self.confirmButton];
    [self.confirmButton autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [self.confirmButton autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.passwordField withOffset:10];
    [self.confirmButton autoPinEdge:ALEdgeLeading toEdge:ALEdgeLeading ofView:self.nameField];
    [self.confirmButton autoPinEdge:ALEdgeTrailing toEdge:ALEdgeTrailing ofView:self.nameField];
    [self.confirmButton autoSetDimension:ALDimensionHeight toSize:44];
}

- (void)confirm
{
    if (0 == self.nameField.text.length || 0 == self.passwordField.text.length) {
        [TipView show:@"用户名和密码不能为空"];
        return;
    }
    
    self.userModel.name = self.nameField.text;
    self.userModel.password = self.passwordField.text;
    
    if ([DataServiceManager sharedManager].isUsingService) {
        [[DataServiceManager sharedManager] registerWithModel:self.userModel response:^(ServiceResponseModel *responseModel) {
            if (responseModel.errorMessage.length > 0) {
                [TipView show:responseModel.errorMessage];
                return;
            }
            HomeViewController *homeViewController = [[HomeViewController alloc] init];
            UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:homeViewController];
            [UIApplication sharedApplication].windows[0].rootViewController = navi;
        }];
        return;
    }
    
    NSArray *allUsers = [[DataManager sharedManager] getAllUsers];
    for (UserModel *model in allUsers) {
        if ([model.phone isEqualToString:self.userModel.phone]) {
            [TipView show:@"该手机号已注册"];
            return;
        }
    }
    
    [[DataManager sharedManager] registerNewUser:self.userModel];
    BOOL loginStatus = [[DataManager sharedManager] loginWithUserName:self.userModel.name password:self.userModel.password];
    if (loginStatus) {
        HomeViewController *homeViewController = [[HomeViewController alloc] init];
        UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:homeViewController];
        [UIApplication sharedApplication].windows[0].rootViewController = navi;
    }
    else
    {
        [TipView show:@"登录失败－－未知错误发生"];
    }
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

#pragma mark - get
- (UserModel *)userModel
{
    if (!_userModel) {
        _userModel = [UserModel new];
    }
    return _userModel;
}

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [UIImageView newAutoLayoutView];
        _imageView.image = [UIImage imageNamed:@"default_avatar"];
    }
    return _imageView;
}

- (UITextField *)nameField
{
    if (!_nameField) {
        _nameField = [TextField newAutoLayoutView];
        _nameField.textInsets = UIEdgeInsetsMake(10, 0, 10, 0);
        _nameField.backgroundColor = [UIColor whiteColor];
        _nameField.layer.borderColor = [UIColor colorWithHexString:@"dddddd"].CGColor;
        _nameField.layer.borderWidth = 0.5;
        _nameField.leftView = [self leftLabel:@"用户名"];
        _nameField.leftViewMode = UITextFieldViewModeAlways;
    }
    return _nameField;
}

- (UITextField *)passwordField
{
    if (!_passwordField) {
        _passwordField = [TextField newAutoLayoutView];
        _passwordField.textInsets = UIEdgeInsetsMake(10, 0, 10, 0);
        _passwordField.backgroundColor = [UIColor whiteColor];
        _passwordField.layer.borderColor = [UIColor colorWithHexString:@"dddddd"].CGColor;
        _passwordField.layer.borderWidth = 0.5;
        _passwordField.leftView = [self leftLabel:@"密    码"];
        _passwordField.leftViewMode = UITextFieldViewModeAlways;
        _passwordField.secureTextEntry = YES;
    }
    return _passwordField;
}

- (UIButton *)confirmButton
{
    if (!_confirmButton) {
        _confirmButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_confirmButton setTitle:@"确认" forState:UIControlStateNormal];
        [_confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _confirmButton.backgroundColor = [UIColor colorWithHexString:@"00ccff"];
        [_confirmButton addTarget:self action:@selector(confirm) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmButton;
}

@end
