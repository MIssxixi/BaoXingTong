//
//  ChangeNameOrPasswordViewController.m
//  BaoXingTong
//
//  Created by yongjie_zou on 16/4/26.
//  Copyright © 2016年 yongjie_zou. All rights reserved.
//

#import "ChangeNameOrPasswordViewController.h"
#import "TextField.h"
#import "DataManager.h"
#import "UserModel.h"
#import "TipView.h"

@interface ChangeNameOrPasswordViewController ()

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *password;

@property (nonatomic, strong) TextField *oldPassWordTextField;
@property (nonatomic, strong) TextField *nameTextField;
@property (nonatomic, strong) TextField *newlyPassWordTextField;
@property (nonatomic, strong) TextField *confirmPassWordTextField;
@property (nonatomic, strong) UIButton *confirmButton;

@end

@implementation ChangeNameOrPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configUI];
}

- (void)configUI
{
    self.view.backgroundColor = MAIN_BACKGROUND_COLOR;
    
    [self.view addSubview:self.oldPassWordTextField];
    [self.oldPassWordTextField autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(68, 15, 0, 15) excludingEdge:ALEdgeBottom];
    [self.oldPassWordTextField autoSetDimension:ALDimensionHeight toSize:44];
    
    [self.view addSubview:self.nameTextField];
    [self.nameTextField autoPinEdge:ALEdgeLeading toEdge:ALEdgeLeading ofView:self.oldPassWordTextField];
    [self.nameTextField autoPinEdge:ALEdgeTrailing toEdge:ALEdgeTrailing ofView:self.oldPassWordTextField];
    [self.nameTextField autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.oldPassWordTextField withOffset:10];
    [self.nameTextField autoSetDimension:ALDimensionHeight toSize:44];
    
    [self.view addSubview:self.newlyPassWordTextField];
    [self.newlyPassWordTextField autoPinEdge:ALEdgeLeading toEdge:ALEdgeLeading ofView:self.oldPassWordTextField];
    [self.newlyPassWordTextField autoPinEdge:ALEdgeTrailing toEdge:ALEdgeTrailing ofView:self.oldPassWordTextField];
    [self.newlyPassWordTextField autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.nameTextField];
    [self.newlyPassWordTextField autoSetDimension:ALDimensionHeight toSize:44];
    
    [self.view addSubview:self.confirmPassWordTextField];
    [self.confirmPassWordTextField autoPinEdge:ALEdgeLeading toEdge:ALEdgeLeading ofView:self.oldPassWordTextField];
    [self.confirmPassWordTextField autoPinEdge:ALEdgeTrailing toEdge:ALEdgeTrailing ofView:self.oldPassWordTextField];
    [self.confirmPassWordTextField autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.newlyPassWordTextField];
    [self.confirmPassWordTextField autoSetDimension:ALDimensionHeight toSize:44];
    
    [self.view addSubview:self.confirmButton];
    [self.confirmButton autoPinEdge:ALEdgeLeading toEdge:ALEdgeLeading ofView:self.oldPassWordTextField];
    [self.confirmButton autoPinEdge:ALEdgeTrailing toEdge:ALEdgeTrailing ofView:self.oldPassWordTextField];
    [self.confirmButton autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.confirmPassWordTextField withOffset:20];
    [self.confirmButton autoSetDimension:ALDimensionHeight toSize:44];
}

- (void)confirm
{
    UserModel *currentUser;
    if ([DataServiceManager sharedManager].isUsingService) {
        currentUser = [DataServiceManager sharedManager].currentUser;
    }
    else
    {
        currentUser = [DataManager sharedManager].currentUser;
    }
    
    if (![currentUser.password isEqualToString:self.oldPassWordTextField.text]) {
        [TipView show:@"旧密码输入错误"];
        return;
    }
    
    if (0 == self.newlyPassWordTextField.text.length) {
        [TipView show:@"请输入新秘密"];
        return;
    }
    
    if (![self.newlyPassWordTextField.text isEqualToString:self.confirmPassWordTextField.text]) {
        [TipView show:@"新密码不一致"];
        return;
    }
    
    if (self.nameTextField.text.length) {
        currentUser.name = self.nameTextField.text;
        if (self.didChangeName) {
            self.didChangeName(currentUser.name);
        }
    }
    currentUser.password = self.newlyPassWordTextField.text;
    if ([DataServiceManager sharedManager].isUsingService) {
        [[DataServiceManager sharedManager] changeName:currentUser.name password:currentUser.password response:^(ServiceResponseModel *responseModel) {
            
        }];
    }
    else
    {
        [[DataManager sharedManager] saveUser:currentUser];
    }
    [self.navigationController popViewControllerAnimated:YES];
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
- (TextField *)oldPassWordTextField
{
    if (!_oldPassWordTextField) {
        _oldPassWordTextField = [TextField new];
        _oldPassWordTextField.textInsets = UIEdgeInsetsMake(12, 0, 12, 0);
        _oldPassWordTextField.backgroundColor = [UIColor whiteColor];
        _oldPassWordTextField.leftView = [self leftLabel:@"旧密码"];
        _oldPassWordTextField.leftViewMode = UITextFieldViewModeAlways;
        _oldPassWordTextField.secureTextEntry = YES;
    }
    return _oldPassWordTextField;
}

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
        _nameTextField.placeholder = [DataManager sharedManager].currentUser.name;
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
        _newlyPassWordTextField.secureTextEntry = YES;
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
        _confirmPassWordTextField.secureTextEntry = YES;
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
