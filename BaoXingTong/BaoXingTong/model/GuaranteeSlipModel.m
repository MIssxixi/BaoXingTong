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
             @"carId":@"carId",
             @"insuranceAgent":@"insuranceAgent",
             @"hasBoughtForceInsurance":@"hasBoughtForceInsurance",
             @"commercialInsurance":@"commercialInsurance",
             @"boughtDate":@"boughtDate",
             @"yearInterval":@"yearInterval",
             @"isNeedRemind":@"isNeedRemind",
             @"remindDate":@"remindDate",
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

- (NSMutableArray <NSString *> *)imageNames
{
    if (!_imageNames) {
        _imageNames = [NSMutableArray new];
    }
    return _imageNames;
}

- (BOOL)isEqual:(id)object
{
    if (self.guaranteeSlipModelId == ((GuaranteeSlipModel *)object).guaranteeSlipModelId) {
        return YES;
    }
    return NO;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"[name = %@, carId = %@, insuranceAgent = %@", self.name, self.carId, self.insuranceAgent];
}

- (void)dealloc
{
    
}

@end
