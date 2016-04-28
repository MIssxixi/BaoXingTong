//
//  GuaranteeSlipModel.h
//  BaoXingTong
//
//  Created by yongjie_zou on 16/3/18.
//  Copyright © 2016年 yongjie_zou. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface GuaranteeSlipModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, assign) NSInteger guaranteeSlipModelId;
@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *IDcard;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *carType;
@property (nonatomic, copy) NSString *carId;
@property (nonatomic, copy) NSString *insuranceAgent;
@property (nonatomic, assign) BOOL hasBoughtForceInsurance;
@property (nonatomic, strong) NSArray <NSString *> *commercialInsurance;
@property (nonatomic, copy) NSString *boughtDate;     // yyyy-MM-dd
@property (nonatomic, copy) NSString *yearInterval;
@property (nonatomic, assign) BOOL isNeedRemind;
@property (nonatomic, copy) NSString *remindDate;
@property (nonatomic, strong) NSMutableArray <UIImage *> *imageArray;

@end
