//
//  AlterView.m
//  BaoXingTong
//
//  Created by yongjie_zou on 16/4/28.
//  Copyright © 2016年 yongjie_zou. All rights reserved.
//

#import "AlterView.h"

@interface AlterView ()

@property (nonatomic,strong) UIAlertController *alertController;
@property (nonatomic, strong) UIViewController *owner;

@end

@implementation AlterView

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message sureAction:(void (^)())sureAction cancelAction:(void (^)())cancelAction owner:(UIViewController *)viewController
{
    self = [super init];
    
    self.owner = viewController;
    //ios>8.0
    self.alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sureAlertAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (sureAction) {
            sureAction();
        }
    }];
    
    UIAlertAction *cancelAlertAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (cancelAction) {
            cancelAction();
        }
    }];
    
    [self.alertController addAction:cancelAlertAction];
    [self.alertController addAction:sureAlertAction];
    return self;
}

- (void)show
{
    [self.owner presentViewController:self.alertController animated:YES completion:nil];
}

@end
