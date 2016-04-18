//
//  ServiceResponseModel.m
//  BaoXingTong
//
//  Created by yongjie_zou on 16/4/15.
//  Copyright © 2016年 yongjie_zou. All rights reserved.
//

#import "ServiceResponseModel.h"

@implementation ServiceResponseModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"errorMessage":@"errorMessage",
             @"data":@"data"
             };
}

- (NSArray *)data
{
    if (!_data) {
        _data = [NSArray new];
    }
    return _data;
}

@end
