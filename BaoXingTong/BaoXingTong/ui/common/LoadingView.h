//
//  LoadingView.h
//  BaoXingTong
//
//  Created by yongjie_zou on 16/5/5.
//  Copyright © 2016年 yongjie_zou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoadingView : NSObject

+ (void)showMessage:(NSString *)message toView:(UIView *)view;
+ (void)hide;

@end
