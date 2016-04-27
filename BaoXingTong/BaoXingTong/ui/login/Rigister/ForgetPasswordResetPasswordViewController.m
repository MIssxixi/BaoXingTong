//
//  ForgerPasswordResetPasswordViewController.m
//  BaoXingTong
//
//  Created by yongjie_zou on 16/4/26.
//  Copyright © 2016年 yongjie_zou. All rights reserved.
//

#import "ForgetPasswordResetPasswordViewController.h"
#import "HomeViewController.h"
#import "TextField.h"
#import "DataManager.h"
#import "UserModel.h"

@interface ForgetPasswordResetPasswordViewController ()

@property (nonatomic, copy) NSString *phoneNumber;

@property (nonatomic, strong) TextField *nameTextField;
@property (nonatomic, strong) TextField *newlyPassWordTextField;
@property (nonatomic, strong) TextField *confirmPassWordTextField;
@property (nonatomic, strong) UIButton *confirmButton;

@end

@implementation ForgetPasswordResetPasswordViewController

- (instancetype)initWithPhoneNumber:(NSString *)phoneNumber
{
    self = [super init];
    if (self) {
        self.phoneNumber = phoneNumber;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"重置密码";
    
    [self configUI];
}

- (void)configUI
{
    self.view.backgroundColor = MAIN_BACKGROUND_COLOR;
    
    [self.view addSubview:self.nameTextField];
    [self.nameTextField autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(122, 15, 0, 15) excludingEdge:ALEdgeBottom];
    [self.nameTextField autoSetDimension:ALDimensionHeight toSize:44];
    
    [self.view addSubview:self.newlyPassWordTextField];
    [self.newlyPassWordTextField autoPinEdge:ALEdgeLeading toEdge:ALEdgeLeading ofView:self.nameTextField];
    [self.newlyPassWordTextField autoPinEdge:ALEdgeTrailing toEdge:ALEdgeTrailing ofView:self.nameTextField];
    [self.newlyPassWordTextField autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.nameTextField];
    [self.newlyPassWordTextField autoSetDimension:ALDimensionHeight toSize:44];
    
    [self.view addSubview:self.confirmPassWordTextField];
    [self.confirmPassWordTextField autoPinEdge:ALEdgeLeading toEdge:ALEdgeLeading ofView:self.nameTextField];
    [self.confirmPassWordTextField autoPinEdge:ALEdgeTrailing toEdge:ALEdgeTrailing ofView:self.nameTextField];
    [self.confirmPassWordTextField autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.newlyPassWordTextField];
    [self.confirmPassWordTextField autoSetDimension:ALDimensionHeight toSize:44];
    
    [self.view addSubview:self.confirmButton];
    [self.confirmButton autoPinEdge:ALEdgeLeading toEdge:ALEdgeLeading ofView:self.nameTextField];
    [self.confirmButton autoPinEdge:ALEdgeTrailing toEdge:ALEdgeTrailing ofView:self.nameTextField];
    [self.confirmButton autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.confirmPassWordTextField withOffset:20];
    [self.confirmButton autoSetDimension:ALDimensionHeight toSize:44];
}

- (void)confirm
{
    if (0 == self.newlyPassWordTextField.text.length) {
        [TipView show:@"请输入新秘密"];
        return;
    }
    
    if (![self.newlyPassWordTextField.text isEqualToString:self.confirmPassWordTextField.text]) {
        [TipView show:@"新密码不一致"];
        return;
    }
    
    UserModel *currentUser = [[DataManager sharedManager] getUserWithPhoneNumber:self.phoneNumber];
    
    if (self.nameTextField.text.length) {
        currentUser.name = self.nameTextField.text;
    }
    currentUser.password = self.newlyPassWordTextField.text;
    [[DataManager sharedManager] saveUser:currentUser];
    [[DataManager sharedManager] loginWithUserName:currentUser.name password:currentUser.password];
    
    HomeViewController *homeViewController = [[HomeViewController alloc] init];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:homeViewController];
    [UIApplication sharedApplication].windows[0].rootViewController = navi;
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
- (TextField *)nameTextField
{
    if (!_nameTextField) {
        _nameTextField = [TextField new];
        _nameTextField.layer.borderWidth = 0.5;
        _nameTextField.layer.borderColor = LINE_GRAY_COLOR;
        _nameTextField.textInsets = UIEdgeInsetsMake(12, 0, 12, 0);
        _nameTextField.backgroundColor = [UIColor whiteColor];
        _nameTextField.leftView = [self leftLabel:@"姓    名"];
        _nameTextField.leftViewMode = UITextFieldViewModeAlways;
        UserModel *model = [[DataManager sharedManager] getUserWithPhoneNumber:self.phoneNumber];
        _nameTextField.placeholder = model.name;
    }
    return _nameTextField;
}

- (TextField *)newlyPassWordTextField
{
    if (!_newlyPassWordTextField) {
        _newlyPassWordTextField = [TextField new];
        _newlyPassWordTextField.layer.borderColor = LINE_GRAY_COLOR;
        _newlyPassWordTextField.layer.borderWidth = 0.5;
        _newlyPassWordTextField.textInsets = UIEdgeInsetsMake(12, 0, 12, 0);
        _newlyPassWordTextField.backgroundColor = [UIColor whiteColor];
        _newlyPassWordTextField.leftView = [self leftLabel:@"新密码"];
        _newlyPassWordTextField.leftViewMode = UITextFieldViewModeAlways;
    }
    return _newlyPassWordTextField;
}

- (TextField *)confirmPassWordTextField
{
    if (!_confirmPassWordTextField) {
        _confirmPassWordTextField = [TextField new];
        _confirmPassWordTextField.layer.borderWidth = 0.5;
        _confirmPassWordTextField.layer.borderColor = LINE_GRAY_COLOR;
        _confirmPassWordTextField.textInsets = UIEdgeInsetsMake(12, 0, 12, 0);
        _confirmPassWordTextField.backgroundColor = [UIColor whiteColor];
        _confirmPassWordTextField.leftView = [self leftLabel:@"确认密码"];
        _confirmPassWordTextField.leftViewMode = UITextFieldViewModeAlways;
    }
    return _confirmPassWordTextField;
}

- (UIButton *)confirmButton
{
    if (!_confirmButton) {
        _confirmButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _confirmButton.backgroundColor = MAIN_BLUE_COLOR;
        [_confirmButton setTitle:@"确认修改" forState:UIControlStateNormal];
        [_confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_confirmButton addTarget:self action:@selector(confirm) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmButton;
}

@end
