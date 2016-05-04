//
//  AlterView.h
//  BaoXingTong
//
//  Created by yongjie_zou on 16/4/28.
//  Copyright © 2016年 yongjie_zou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlterView : NSObject

@property (nonatomic, copy) void (^sureAction)();
@property (nonatomic, copy) void (^cancelAction)();

- initWithTitle:(NSString *)title message:(NSString *)message sureAction:(void (^)())sureAction cancelAction:(void (^)())cancelAction owner:(UIViewController *)viewController;
- (void)show;

@end
