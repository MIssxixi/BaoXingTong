//
//  UserModel.m
//  BaoXingTong
//
//  Created by yongjie_zou on 16/4/25.
//  Copyright © 2016年 yongjie_zou. All rights reserved.
//

#import "UserModel.h"

@implementation UserModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"name":@"name",
             @"password":@"password",
             @"phone":@"phone"
             };
}

@end
