//
//  HtmlManager.m
//  BaoXingTong
//
//  Created by yongjie_zou on 16/4/27.
//  Copyright © 2016年 yongjie_zou. All rights reserved.
//

#import "HtmlManager.h"
#import "GuaranteeSlipModel.h"

@implementation HtmlManager

static HtmlManager *sharedManager;      //这个必须在+ (instancetype)sharedManager方法外声明吗？因为作用域的关系？

+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[HtmlManager alloc] init];
    });
    return sharedManager;
}

@end
