//
//  TipView.m
//  BaoXingTong
//
//  Created by yongjie_zou on 16/4/8.
//  Copyright © 2016年 yongjie_zou. All rights reserved.
//

#import "TipView.h"
#import <MBProgressHUD/MBProgressHUD.h>

@implementation TipView

+ (void)show:(NSString *)message
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = @"名字不能为空";
    [hud hide:YES afterDelay:1];
}

@end
