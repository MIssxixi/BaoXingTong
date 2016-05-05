//
//  LoadingView.m
//  BaoXingTong
//
//  Created by yongjie_zou on 16/5/5.
//  Copyright © 2016年 yongjie_zou. All rights reserved.
//

#import "LoadingView.h"

@interface LoadingView ()

@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation LoadingView

+ (LoadingView *)shareInstance
{
    static LoadingView *shareInstance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        shareInstance = [[self alloc] init];
    });
    return shareInstance;
}

+ (void)showMessage:(NSString *)message toView:(UIView *)view
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeDeterminate;
    hud.labelText = message;
    [self shareInstance].hud = hud;
}

+ (void)hide
{
    [[self shareInstance].hud hide:YES];
}

@end
