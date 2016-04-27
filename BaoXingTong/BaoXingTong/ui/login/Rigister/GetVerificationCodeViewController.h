//
//  RegisterViewController.h
//  BaoXingTong
//
//  Created by yongjie_zou on 16/4/26.
//  Copyright © 2016年 yongjie_zou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TextField.h"

@interface GetVerificationCodeViewController : UIViewController

@property (nonatomic, readonly, strong) TextField *phoneField;

- (void)nextAction;

@end
