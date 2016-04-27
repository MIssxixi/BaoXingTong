//
//  ForgetPasswordViewController.m
//  BaoXingTong
//
//  Created by yongjie_zou on 16/4/26.
//  Copyright © 2016年 yongjie_zou. All rights reserved.
//

#import "ForgetPasswordGetVerificationCodeViewController.h"
#import "ForgetPasswordVerificationViewController.h"
#import "DataManager.h"
#import "UserModel.h"

@interface ForgetPasswordGetVerificationCodeViewController ()

@end

@implementation ForgetPasswordGetVerificationCodeViewController

- (void)nextAction
{
    NSArray *allUsers = [[DataManager sharedManager] getAllUsers];
    BOOL userExist = NO;
    for (UserModel *model in allUsers) {
        if ([model.phone isEqualToString:self.phoneField.text]) {
            userExist = YES;
        }
    }
    
    if (!userExist) {
        [TipView show:@"该手机号还未注册"];
        return;
    }
    
    WS(weakSelf)
    [SMSSDK getVerificationCodeByMethod:SMSGetCodeMethodSMS phoneNumber:self.phoneField.text zone:@"86" customIdentifier:nil result:^(NSError *error) {
        if (error) {
            [TipView show:[error.userInfo valueForKey:@"getVerificationCode"]];
        }
        else
        {
            [TipView show:@"短信发送成功"];
            ForgetPasswordVerificationViewController *verificationViewController = [[ForgetPasswordVerificationViewController alloc] initWithPhone:weakSelf.phoneField.text];
            [weakSelf.navigationController pushViewController:verificationViewController animated:YES];
        }
    }];
}

@end
