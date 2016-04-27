//
//  verificationViewController.h
//  BaoXingTong
//
//  Created by yongjie_zou on 16/4/26.
//  Copyright © 2016年 yongjie_zou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TextField.h"

@interface VerificationViewController : UIViewController

@property (nonatomic, readonly, copy) NSString *phoneNumber;
@property (nonatomic, readonly, strong) TextField *verificationCodeTextField;

- (instancetype)initWithPhone:(NSString *)phone;
- (void)nextAction;

@end
