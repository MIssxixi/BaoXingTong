//
//  GuaranteeSlipModel.m
//  BaoXingTong
//
//  Created by yongjie_zou on 16/3/18.
//  Copyright © 2016年 yongjie_zou. All rights reserved.
//

#import "GuaranteeSlipModel.h"

@implementation GuaranteeSlipModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"guaranteeSlipModelId":@"guaranteeSlipModelId",
             @"name":@"name",
             @"IDcard":@"IDcard",
             @"phone":@"phone",
             @"carType":@"carType",
             @"insuranceAgent":@"insuranceAgent",
             @"hasBoughtForceInsurance":@"hasBoughtForceInsurance",
             @"commercialInsurance":@"commercialInsurance",
             @"boughtDate":@"boughtDate",
             @"yearInterval":@"yearInterval",
             @"isNeedRemind":@"isNeedRemind",
             @"imageArray":@"imageArray",
             };
}

- (NSArray <NSString *> *)commercialInsurance
{
    if (!_commercialInsurance) {
        _commercialInsurance = [NSArray new];
    }
    return _commercialInsurance;
}

- (NSMutableArray <UIImage *> *)imageArray
{
    if (!_imageArray) {
        _imageArray = [NSMutableArray new];
    }
    return _imageArray;
}

@end
