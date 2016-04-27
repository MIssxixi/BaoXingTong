//
//  ForgetPasswordVerificationViewController.m
//  BaoXingTong
//
//  Created by yongjie_zou on 16/4/26.
//  Copyright © 2016年 yongjie_zou. All rights reserved.
//

#import "ForgetPasswordVerificationViewController.h"
#import "ForgetPasswordResetPasswordViewController.h"

@interface ForgetPasswordVerificationViewController ()

@end

@implementation ForgetPasswordVerificationViewController

- (void)nextAction
{
    WS(weakSelf)
    [SMSSDK commitVerificationCode:self.verificationCodeTextField.text phoneNumber:self.phoneNumber zone:@"86" result:^(NSError *error) {
        if (error) {
            [TipView show:[error.userInfo valueForKey:@"commitVerificationCode"]];
        }
        else
        {
            [TipView show:@"验证成功"];
            ForgetPasswordResetPasswordViewController *registerViewController = [[ForgetPasswordResetPasswordViewController alloc] initWithPhoneNumber:weakSelf.phoneNumber];
            [weakSelf.navigationController pushViewController:registerViewController animated:YES];
        }
    }];
}

@end
